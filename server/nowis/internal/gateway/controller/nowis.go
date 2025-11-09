package controllers

import (
	"context"
	"log"
	"net/http"
	model "nowis/internal/gateway/model"
	"nowis/pkg/configs"
	sfgrpc "nowis/pkg/network"
	nowispb "nowis/protobuf/generated/nowis"
	"strconv"

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

	post, err := model.FromPBPost(response.Post)
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

func (controller *NowisController) HealthCheck(ginContext *gin.Context) {
	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().NowisPublicAddress,
	)

	if err != nil {
		log.Printf("[Nowis] Error when connecting to NowisService: %v", err)
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	response, err := nowisService.HealthCheck(context.Background(), &nowispb.HealthCheckRequest{})

	if err != nil {
		log.Printf("error when calling NowisService HealthCheck: %v", err)
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	healthCheckResponse := model.FromPBHealthCheckResponse(response)

	ginContext.JSON(
		http.StatusOK,
		gin.H{
			"success": true,
			"data":    healthCheckResponse.ToGinMap(),
			"message": "Health check successful",
		},
	)
}

func (controller *NowisController) GetPostBySlug(ginContext *gin.Context) {
	slug := ginContext.Param("slug")
	lang := ginContext.GetHeader("lang")

	if slug == "" {
		ginContext.JSON(
			http.StatusBadRequest,
			gin.H{
				"success": false,
				"message": "Invalid slug",
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
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	response, err := nowisService.GetPostBySlug(context.Background(), &nowispb.GetPostBySlugRequest{
		Slug: slug,
		Locale: &nowispb.Locale{
			Lang: lang,
		},
	})

	if err != nil {
		log.Printf("error when calling NowisService GetPostBySlug: %v", err)
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

	post, err := model.FromPBPost(response.Post)
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

func (controller *NowisController) GetPosts(ginContext *gin.Context) {
	lang := ginContext.GetHeader("lang")
	pageStr := ginContext.DefaultQuery("page", "1")
	limitStr := ginContext.DefaultQuery("limit", "10")
	searchQuery := ginContext.Query("search_query")

	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		limit = 10
	}

	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().NowisPublicAddress,
	)

	if err != nil {
		log.Printf("[Nowis] Error when connecting to NowisService: %v", err)
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	response, err := nowisService.GetPosts(context.Background(), &nowispb.GetPostsRequest{
		Page:  int32(page),
		Limit: int32(limit),
		Locale: &nowispb.Locale{
			Lang: lang,
		},
		SearchQuery: searchQuery,
	})

	if err != nil {
		log.Printf("error when calling NowisService GetPosts: %v", err)
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

	var formattedPosts []map[string]interface{}
	for _, pbPost := range response.Posts {
		post, err := model.FromPBPost(pbPost)
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
		formattedPosts = append(formattedPosts, post.ToGinMap())
	}

	ginContext.JSON(
		http.StatusOK,
		gin.H{
			"success": true,
			"data":    formattedPosts,
			"message": "Success",
		},
	)
}

func (controller *NowisController) GetSidebarPostsByTags(ginContext *gin.Context) {
	tagNameFilter := ginContext.Query("tag_name_filter")

	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().NowisPublicAddress,
	)

	if err != nil {
		log.Printf("[Nowis] Error when connecting to NowisService: %v", err)
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	response, err := nowisService.GetSidebarPostsByTags(context.Background(), &nowispb.GetSidebarPostsByTagsRequest{
		TagNameFilter: tagNameFilter,
	})

	if err != nil {
		log.Printf("error when calling NowisService GetSidebarPostsByTags: %v", err)
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

	var formattedTags []map[string]interface{}
	for _, pbTagSidebar := range response.Tags {
		tagSidebar := model.FromPBTagSidebar(pbTagSidebar)
		formattedTags = append(formattedTags, tagSidebar.ToGinMap())
	}

	ginContext.JSON(
		http.StatusOK,
		gin.H{
			"success": true,
			"data":    formattedTags,
			"message": "Success",
		},
	)
}
