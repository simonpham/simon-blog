package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"
	"time"

	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	healthgrpc "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"

	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors"
	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/auth"
	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/selector"

	gatewayRouter "nowis/internal/gateway/router"
	nowisRepo "nowis/internal/nowis/repository"
	nowis "nowis/internal/nowis/service"
	"nowis/pkg/configs"
	"nowis/pkg/db"
	localInterceptors "nowis/pkg/interceptors"
	nowispb "nowis/protobuf/generated/nowis"
)

// grpcHandlerFunc is a unified handler that routes gRPC traffic (detected by HTTP/2 and content-type)
// to the gRPC server, and all other traffic to the standard HTTP handler (Gin).
func grpcHandlerFunc(grpcServer *grpc.Server, httpHandler http.Handler) http.Handler {
	return h2c.NewHandler(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.ProtoMajor == 2 && strings.Contains(r.Header.Get("Content-Type"), "application/grpc") {
			grpcServer.ServeHTTP(w, r)
		} else {
			httpHandler.ServeHTTP(w, r)
		}
	}), &http2.Server{})
}

func main() {
	config := configs.GetConfig()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	var wg sync.WaitGroup
	errChan := make(chan error, 1)

	// --- Single Port Listener Setup (Plain TCP) ---
	lis, err := net.Listen("tcp", config.NowisInternalAddress)
	if err != nil {
		log.Fatalf("failed to listen on shared address: %v", err)
	}

	authDb, err := db.OpenAuthDatabase()
	if err != nil {
		log.Fatalf("[AuthService] Error opening database: %v", err)
	}

	repo := nowisRepo.NewNowisRepository(authDb)
	server := nowis.NewNowisService(repo)

	// --- Gin Server Setup ---
	r := gatewayRouter.InitApi()

	// --- gRPC Server Setup ---
	var opts []grpc.ServerOption
	opts = append(opts, grpc.Creds(insecure.NewCredentials()))

	// Auth Matcher
	authMatcher := func(ctx context.Context, callMeta interceptors.CallMeta) bool {
		return callMeta.FullMethod() == "/nowis.NowisService/CreatePost"
	}

	opts = append(opts, grpc.ChainUnaryInterceptor(
		selector.UnaryServerInterceptor(
			auth.UnaryServerInterceptor(localInterceptors.AuthInterceptor),
			selector.MatchFunc(authMatcher),
		),
		localInterceptors.ValidationInterceptor,
	))

	grpcSrv := grpc.NewServer(opts...)
	nowispb.RegisterNowisServiceServer(grpcSrv, &server)

	healthcheck := nowis.NewNowisHealthService()
	healthgrpc.RegisterHealthServer(grpcSrv, healthcheck)

	if config.Env == "debug" {
		reflection.Register(grpcSrv)
	}

	// --- Unified Handler Setup (Combining Gin and gRPC) ---
	unifiedHandler := grpcHandlerFunc(grpcSrv, r)

	ginSrv := &http.Server{
		Handler: unifiedHandler,
	}

	// --- Start Unified Server ---
	wg.Add(1)
	go func() {
		defer wg.Done()
		log.Printf("[Unified Server] Started on address (%s)", lis.Addr().String())
		// This single server handles both HTTP/1.1 and H2C (gRPC) traffic
		if err := ginSrv.Serve(lis); err != nil && err != http.ErrServerClosed {
			errChan <- fmt.Errorf("unified server failed to run: %w", err)
		}
	}()

	// --- Block and Wait for Signal/Error ---
	select {
	case err := <-errChan:
		log.Fatalf("Fatal error detected, initiating shutdown: %v", err)
	case <-quit:
		log.Println("Received shutdown signal. Initiating graceful shutdown...")
	}

	// --- Graceful Shutdown Execution ---
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	log.Println("Stopping gRPC Server...")
	// GracefulStop on the gRPC server is called directly,
	// which is safe even if it's served via the unified handler.
	grpcSrv.GracefulStop()

	log.Println("Stopping Gin/Unified Server...")
	if err := ginSrv.Shutdown(ctx); err != nil {
		log.Printf("Unified Server shutdown error (may be forced): %v", err)
	}

	wg.Wait()

	log.Println("All servers stopped. Exiting application.")
}
