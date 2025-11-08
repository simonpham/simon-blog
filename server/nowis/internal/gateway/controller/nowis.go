package controllers

import (
	"context"
	"log"
	"net/http"
	model "nowis/internal/gateway/model"
	"nowis/pkg/configs"
	sfgrpc "nowis/pkg/network"
	nowispb "nowis/protobuf/generated/nowis"

	"github.com/gin-gonic/gin"
)

type NowisController struct {
}

func NewNowisController() NowisController {
	return NowisController{}
}

func (controller *NowisController) GetPostById(ginContext *gin.Context) {
	id := ginContext.Param("id")
	lang := ginContext.GetHeader("lang")

	if id == "" {
		ginContext.JSON(
			http.StatusBadRequest,
			gin.H{
				"success": false,
				"message": "Invalid ID",
			},
		)
		return
	}

	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().NowisPublicAddress,
	)

	if err != nil {
		log.Printf("[Nowis] Error when connecting to NowisService: %v", err)
	}

	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	response, err := nowisService.GetPostById(context.Background(), &nowispb.GetPostByIdRequest{
		Id: id,
		Locale: &nowispb.Locale{
			Lang: lang,
		},
	})

	if err != nil {
		log.Printf("error when calling NowisService: %v", err)
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	log.Printf("Response from server: %v", response)

	var post *model.Post
	post, err = model.FromPBPost(response.Post)
	if err != nil {
		log.Printf("error when converting post: %v", err)
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	ginContext.JSON(
		http.StatusOK,
		gin.H{
			"success": true,
			"data":    post.ToGinMap(),
			"message": "Success",
		},
	)
}
