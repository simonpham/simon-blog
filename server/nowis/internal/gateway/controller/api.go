package controllers

import (
	"context"
	"log"
	"net/http"
	"nowis/pkg/configs"
	sfgrpc "nowis/pkg/network"

	"github.com/gin-gonic/gin"
	healthgrpc "google.golang.org/grpc/health/grpc_health_v1"
)

type ApiController struct {
}

func NewApiController() ApiController {
	return ApiController{}
}

func (controller *ApiController) Health(ginContext *gin.Context) {
	config := configs.GetConfig()

	/// Auth service health check.
	authConn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		config.AuthPublicAddress,
	)

	if err != nil {
		log.Printf("[Health] Error when connecting to AuthService: %v", err)
	}

	defer authConn.Close()

	authHealth := healthgrpc.NewHealthClient(authConn)

	authStatus, err := authHealth.Check(context.Background(), &healthgrpc.HealthCheckRequest{
		Service: "AuthService",
	})
	if err != nil {
		log.Printf("[Health] Error when calling AuthService.HealthCheck: %v", err)
	}

	/// Nowis service health check.
	nowisConn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		config.NowisPublicAddress,
	)

	if err != nil {
		log.Printf("[Health] Error when connecting to NowisService: %v", err)
	}

	defer nowisConn.Close()

	nowisHealth := healthgrpc.NewHealthClient(nowisConn)

	nowisStatus, err := nowisHealth.Check(context.Background(), &healthgrpc.HealthCheckRequest{
		Service: "NowisService",
	})
	if err != nil {
		log.Printf("[Health] Error when calling NowisService.HealthCheck: %v", err)
	}

	/// Gateway service health check.
	gatewayResponse, err := http.Get(config.NowisPublicAddress + "/api/health")

	if err != nil {
		log.Printf("[Health] Error when calling Lair.HealthCheck: %v", err)
	}

	var gatewayStatus gin.H
	if gatewayResponse != nil {
		gatewayStatus = gin.H{
			"status": gatewayResponse.StatusCode,
		}
	}

	ginContext.JSON(
		200,
		gin.H{
			"gateway": gatewayStatus,
			"auth":    authStatus,
			"nowis":   nowisStatus,
		},
	)
}
