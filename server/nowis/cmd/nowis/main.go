package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/soheilhy/cmux"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	healthgrpc "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"

	nowisRepo "nowis/internal/nowis/repository"
	nowis "nowis/internal/nowis/service"
	"nowis/pkg/configs"
	"nowis/pkg/db"
	"nowis/pkg/interceptors"
	nowispb "nowis/protobuf/generated/nowis"
)

func main() {
	config := configs.GetConfig()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	var wg sync.WaitGroup
	errChan := make(chan error, 3)

	// --- Single Port Listener Setup ---
	lis, err := net.Listen("tcp", config.NowisInternalAddress)
	if err != nil {
		log.Fatalf("failed to listen on shared address: %v", err)
	}

	mux := cmux.New(lis)
	grpcL := mux.Match(cmux.HTTP2HeaderField("content-type", "application/grpc"))
	httpL := mux.Match(cmux.Any())

	authDb, err := db.OpenAuthDatabase()
	if err != nil {
		log.Fatalf("[AuthService] Error opening database: %v", err)
	}

	repo := nowisRepo.NewNowisRepository(authDb)
	server := nowis.NewNowisService(repo)

	// --- gRPC Server Setup and Start ---
	var opts []grpc.ServerOption
	opts = append(opts, grpc.Creds(insecure.NewCredentials()))
	opts = append(opts, grpc.UnaryInterceptor(interceptors.ValidationInterceptor))

	srv := grpc.NewServer(opts...)
	nowispb.RegisterNowisServiceServer(srv, &server)

	healthcheck := nowis.NewNowisHealthService()
	healthgrpc.RegisterHealthServer(srv, healthcheck)

	if config.Env == "debug" {
		reflection.Register(srv)
	}

	wg.Add(1)
	go func() {
		defer wg.Done()
		log.Printf("[gRPC Server] Started on shared listener (%s)", lis.Addr().String())
		if err := srv.Serve(grpcL); err != nil && err != grpc.ErrServerStopped {
			errChan <- fmt.Errorf("gRPC server failed to serve: %w", err)
		}
	}()

	// --- Gin Server Setup and Start ---
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "pong"})
	})

	ginSrv := &http.Server{
		Handler: r,
	}

	wg.Add(1)
	go func() {
		defer wg.Done()
		log.Printf("[Gin Server] Started on shared listener (%s)", lis.Addr().String())
		if err := ginSrv.Serve(httpL); err != nil && err != http.ErrServerClosed {
			errChan <- fmt.Errorf("Gin server failed to run: %w", err)
		}
	}()

	// --- cmux Listener Start ---
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := mux.Serve(); err != nil && err != net.ErrClosed {
			errChan <- fmt.Errorf("cmux failed to serve: %w", err)
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

	// Close the base listener first to stop accepting new connections
	lis.Close()

	log.Println("Stopping gRPC Server...")
	srv.GracefulStop()

	log.Println("Stopping Gin Server...")
	if err := ginSrv.Shutdown(ctx); err != nil {
		log.Printf("Gin Server shutdown error (may be forced): %v", err)
	}

	wg.Wait()

	log.Println("All servers stopped. Exiting application.")
}
