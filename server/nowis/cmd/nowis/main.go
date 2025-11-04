package main

import (
	nowis "nowis/internal/nowis/service"
	"nowis/pkg/configs"
	"nowis/pkg/interceptors"
	nowispb "nowis/protobuf/generated/nowis"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	healthgrpc "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"
	"log"
	"net"
)

func main() {
	config := configs.GetConfig()

	lis, err := net.Listen("tcp", config.NowisInternalAddress)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	log.Printf("[NowisService] Listening at: %s", lis.Addr().String())

	server := nowis.NewNowisService()

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

	log.Printf("[NowisService] Started at %s", lis.Addr().String())

	err = srv.Serve(lis)
	if err != nil {
		log.Fatalf("[NowisService] Error serving: %v", err)
		return
	}
}
