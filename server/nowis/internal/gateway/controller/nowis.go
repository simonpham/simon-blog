package controllers

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"text/template"

	model "nowis/internal/gateway/model"
	"nowis/pkg/configs"
	sfgrpc "nowis/pkg/network"
	nowispb "nowis/protobuf/generated/nowis"

	"github.com/gin-gonic/gin"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type NowisController struct {
	Templates *template.Template
}

func NewNowisController() NowisController {
	tmpl, err := template.New("post_summary.html").Parse(postSummaryTemplate)
	if err != nil {
		log.Fatalf("Error parsing template: %v", err)
	}
	return NowisController{Templates: tmpl}
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

func (controller *NowisController) GetPostSummaryJsonBySlug(ginContext *gin.Context) {
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
		log.Printf("error when calling NowisService GetPostBySlug for summary: %v", err)
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	post, err := model.FromPBPost(response.Post)
	if err != nil {
		log.Printf("error when converting post for summary: %v", err)
		ginContext.JSON(
			http.StatusInternalServerError,
			gin.H{
				"success": false,
				"message": "Internal server error",
			},
		)
		return
	}

	summaryPost := model.SummaryPost{
		ID:               post.ID,
		Title:            post.Title,
		Slug:             post.Slug,
		Summary:          post.Summary,
		FeaturedImageURL: post.FeaturedImageURL,
		Author:           post.Author,
		CreatedAt:        post.CreatedAt,
		UpdatedAt:        post.UpdatedAt,
		Tags:             post.Tags,
	}

	ginContext.JSON(
		http.StatusOK,
		gin.H{
			"success": true,
			"data":    summaryPost.ToGinMap(),
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

func (controller *NowisController) CreateComment(ginContext *gin.Context) {
	var reqBody model.CreateCommentRequestBody
	if err := ginContext.ShouldBindJSON(&reqBody); err != nil {
		ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": fmt.Sprintf("Invalid request body: %v", err)})
		return
	}

	if reqBody.PostId == "" || reqBody.Content == "" || reqBody.Animal == "" || reqBody.BackgroundColor == "" {
		ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "All fields (post_id, content, animal, background_color) are required"})
		return
	}

	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().NowisPublicAddress,
	)
	if err != nil {
		log.Printf("[Nowis] Error when connecting to NowisService: %v", err)
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}
	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	response, err := nowisService.CreateComment(context.Background(), &nowispb.CreateCommentRequest{
		PostId:          reqBody.PostId,
		Content:         reqBody.Content,
		Animal:          reqBody.Animal,
		BackgroundColor: reqBody.BackgroundColor,
	})

	if err != nil {
		log.Printf("error when calling NowisService CreateComment: %v", err)
		st, ok := status.FromError(err)
		if ok {
			switch st.Code() {
			case codes.InvalidArgument:
				ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": st.Message()})
				return
			case codes.NotFound:
				ginContext.JSON(http.StatusNotFound, gin.H{"success": false, "message": st.Message()})
				return
			default:
				ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
				return
			}
		}
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}

	log.Printf("Response from server: %v", response)

	comment := model.FromPBComment(response.Comment)

	ginContext.JSON(
		http.StatusCreated,
		gin.H{
			"success": true,
			"data":    comment.ToGinMap(),
			"message": "Comment created successfully",
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

func (controller *NowisController) GetComments(ginContext *gin.Context) {
	postId := ginContext.Query("postId")
	if postId == "" {
		ginContext.JSON(
			http.StatusBadRequest,
			gin.H{
				"success": false,
				"message": "Missing postId",
			},
		)
		return
	}

	limit, err := strconv.Atoi(ginContext.Query("limit"))
	if err != nil {
		limit = 10
	}

	page, err := strconv.Atoi(ginContext.Query("page"))
	if err != nil {
		page = 1
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

	response, err := nowisService.GetPostComments(context.Background(), &nowispb.GetPostCommentsRequest{
		PostId: postId,
		Limit:  int32(limit),
		Page:   int32(page),
	})

	if err != nil {
		log.Printf("error when calling NowisService GetComments: %v", err)
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

	var formattedComments []map[string]interface{}
	for _, pbComment := range response.Comments {
		comment := model.FromPBComment(pbComment)
		formattedComments = append(formattedComments, comment.ToGinMap())
	}

	ginContext.JSON(
		http.StatusOK,
		gin.H{
			"success": true,
			"data":    formattedComments,
			"message": "Success",
		},
	)
}

func (controller *NowisController) CreatePost(ginContext *gin.Context) {
	var reqBody model.CreatePostRequestBody
	if err := ginContext.ShouldBindJSON(&reqBody); err != nil {
		ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": fmt.Sprintf("Invalid request body: %v", err)})
		return
	}

	authHeader := ginContext.GetHeader("Authorization")
	if authHeader == "" {
		ginContext.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Missing Authorization header"})
		return
	}

	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().NowisPublicAddress,
	)
	if err != nil {
		log.Printf("[Nowis] Error when connecting to NowisService: %v", err)
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}
	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	var statusPb nowispb.PostStatus
	switch reqBody.Status {
	case model.PostStatusDraft:
		statusPb = nowispb.PostStatus_draft
	case model.PostStatusPublished:
		statusPb = nowispb.PostStatus_published
	case model.PostStatusArchived:
		statusPb = nowispb.PostStatus_archived
	default:
		statusPb = nowispb.PostStatus_draft
	}

	var visibilityPb nowispb.PostVisibility
	switch reqBody.Visibility {
	case model.PostVisibilityPublic:
		visibilityPb = nowispb.PostVisibility_public
	case model.PostVisibilityPrivate:
		visibilityPb = nowispb.PostVisibility_private
	case model.PostVisibilityUnlisted:
		visibilityPb = nowispb.PostVisibility_unlisted
	default:
		visibilityPb = nowispb.PostVisibility_private
	}

	ctx := metadata.AppendToOutgoingContext(context.Background(), "authorization", authHeader)

	response, err := nowisService.CreatePost(ctx, &nowispb.CreatePostRequest{
		Title:            reqBody.Title,
		Content:          reqBody.Content,
		Summary:          reqBody.Summary,
		FeaturedImageUrl: reqBody.FeaturedImageURL,
		Status:           statusPb,
		Visibility:       visibilityPb,
		Tags:             reqBody.Tags,
	})

	if err != nil {
		log.Printf("error when calling NowisService CreatePost: %v", err)
		st, ok := status.FromError(err)
		if ok {
			switch st.Code() {
			case codes.InvalidArgument:
				ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": st.Message()})
				return
			case codes.Unauthenticated:
				ginContext.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": st.Message()})
				return
			case codes.Internal:
				ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": st.Message()})
				return
			default:
				ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
				return
			}
		}
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}

	log.Printf("Response from server: %v", response)

	post, err := model.FromPBPost(response.Post)
	if err != nil {
		log.Printf("error when converting post: %v", err)
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}

	ginContext.JSON(
		http.StatusCreated,
		gin.H{
			"success": true,
			"data":    post.ToGinMap(),
			"message": "Post created successfully",
		},
	)
}

func (controller *NowisController) UpdatePost(ginContext *gin.Context) {
	id := ginContext.Param("id")
	if id == "" {
		ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid ID"})
		return
	}

	var reqBody model.UpdatePostRequestBody
	if err := ginContext.ShouldBindJSON(&reqBody); err != nil {
		ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": fmt.Sprintf("Invalid request body: %v", err)})
		return
	}

	authHeader := ginContext.GetHeader("Authorization")
	if authHeader == "" {
		ginContext.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Missing Authorization header"})
		return
	}

	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().NowisPublicAddress,
	)
	if err != nil {
		log.Printf("[Nowis] Error when connecting to NowisService: %v", err)
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}
	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	var statusPb nowispb.PostStatus
	switch reqBody.Status {
	case model.PostStatusDraft:
		statusPb = nowispb.PostStatus_draft
	case model.PostStatusPublished:
		statusPb = nowispb.PostStatus_published
	case model.PostStatusArchived:
		statusPb = nowispb.PostStatus_archived
	default:
		statusPb = nowispb.PostStatus_draft
	}

	var visibilityPb nowispb.PostVisibility
	switch reqBody.Visibility {
	case model.PostVisibilityPublic:
		visibilityPb = nowispb.PostVisibility_public
	case model.PostVisibilityPrivate:
		visibilityPb = nowispb.PostVisibility_private
	case model.PostVisibilityUnlisted:
		visibilityPb = nowispb.PostVisibility_unlisted
	default:
		visibilityPb = nowispb.PostVisibility_private
	}

	ctx := metadata.AppendToOutgoingContext(context.Background(), "authorization", authHeader)

	response, err := nowisService.UpdatePost(ctx, &nowispb.UpdatePostRequest{
		PostId:           id,
		Title:            reqBody.Title,
		Content:          reqBody.Content,
		Summary:          reqBody.Summary,
		FeaturedImageUrl: reqBody.FeaturedImageURL,
		Status:           statusPb,
		Visibility:       visibilityPb,
		Tags:             reqBody.Tags,
	})

	if err != nil {
		log.Printf("error when calling NowisService UpdatePost: %v", err)
		st, ok := status.FromError(err)
		if ok {
			switch st.Code() {
			case codes.InvalidArgument:
				ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": st.Message()})
				return
			case codes.Unauthenticated:
				ginContext.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": st.Message()})
				return
			case codes.PermissionDenied:
				ginContext.JSON(http.StatusForbidden, gin.H{"success": false, "message": st.Message()})
				return
			case codes.NotFound:
				ginContext.JSON(http.StatusNotFound, gin.H{"success": false, "message": st.Message()})
				return
			case codes.Internal:
				ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": st.Message()})
				return
			default:
				ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
				return
			}
		}
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}

	log.Printf("Response from server: %v", response)

	post, err := model.FromPBPost(response.Post)
	if err != nil {
		log.Printf("error when converting post: %v", err)
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}

	ginContext.JSON(
		http.StatusOK,
		gin.H{
			"success": true,
			"data":    post.ToGinMap(),
			"message": "Post updated successfully",
		},
	)
}

func (controller *NowisController) GetUser(ginContext *gin.Context) {
	id := ginContext.Param("id")
	if id == "" {
		ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid ID"})
		return
	}

	conn, err := sfgrpc.CreateGrpcClientConnection(
		context.Background(),
		configs.GetConfig().NowisPublicAddress,
	)
	if err != nil {
		log.Printf("[Nowis] Error when connecting to NowisService: %v", err)
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}
	defer conn.Close()

	nowisService := nowispb.NewNowisServiceClient(conn)

	response, err := nowisService.GetUser(context.Background(), &nowispb.GetUserRequest{
		Id: id,
	})

	if err != nil {
		log.Printf("error when calling NowisService GetUser: %v", err)
		st, ok := status.FromError(err)
		if ok {
			switch st.Code() {
			case codes.InvalidArgument:
				ginContext.JSON(http.StatusBadRequest, gin.H{"success": false, "message": st.Message()})
				return
			case codes.NotFound:
				ginContext.JSON(http.StatusNotFound, gin.H{"success": false, "message": st.Message()})
				return
			default:
				ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
				return
			}
		}
		ginContext.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Internal server error"})
		return
	}

	user := response.User
	userMap := map[string]interface{}{
		"id":           user.Id,
		"username":     user.Username,
		"email":        user.Email,
		"display_name": user.DisplayName,
		"avatar_url":   user.AvatarUrl,
		"avatar_hash":  user.AvatarHash,
		"bio":          user.Bio,
		"created_at":   user.CreatedAt,
		"updated_at":   user.UpdatedAt,
	}

	ginContext.JSON(
		http.StatusOK,
		gin.H{
			"success": true,
			"data":    userMap,
			"message": "Success",
		},
	)
}
