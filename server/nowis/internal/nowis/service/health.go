package service

import (
	"google.golang.org/grpc/health"
	healthgrpc "google.golang.org/grpc/health/grpc_health_v1"
)

type NowisHealthService struct {
	*health.Server
}

func NewNowisHealthService() NowisHealthService {
	server := NowisHealthService{
		Server: health.NewServer(),
	}
	server.SetServingStatus("NowisService", healthgrpc.HealthCheckResponse_SERVING)

	return server
}
