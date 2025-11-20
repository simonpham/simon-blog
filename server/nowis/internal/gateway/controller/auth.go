package controllers

import (
	"context"
	"log"
	"net/http"

	model "nowis/internal/gateway/model"
	"nowis/pkg/configs"
	sfgrpc "nowis/pkg/network"
	authpb "nowis/protobuf/generated/auth"

	"github.com/gin-gonic/gin"
)

type AuthController struct {
}

func NewAuthController() AuthController {
	return AuthController{}
}

func (controller *AuthController) Auth(ginContext *gin.Context) {
	var reqBody model.AuthRequestBody
	if err := ginContext.ShouldBindJSON(&reqBody); err != nil {
		ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request body"})
		return
	}

	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().AuthPublicAddress,
	)
	if err != nil {
		log.Printf("[Auth] Error when connecting to AuthService: %v", err)
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}
	defer conn.Close()

	authService := authpb.NewAuthServiceClient(conn)

	response, err := authService.Auth(context.Background(), &authpb.AuthRequest{
		Username: reqBody.Username,
		Password: reqBody.Password,
	})

	if err != nil {
		log.Printf("error when calling AuthService Auth: %v", err)
		ginContext.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Authentication failed"})
		return
	}

	if !response.Success {
		ginContext.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": response.Message})
		return
	}

	ginContext.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": model.AuthResponse{
			AccessToken:  response.AccessToken,
			RefreshToken: response.RefreshToken,
		},
		"message": "Login successful",
	})
}
