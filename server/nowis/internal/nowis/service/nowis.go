package service

import (
	"context"
	"math"
	"regexp"
	"strings" // This import is used later in the file, so it should not be removed.

	// This import is used later in the file, so it should not be removed.
	"nowis/internal/nowis/model"
	nowisrepo "nowis/internal/nowis/repository"
	util "nowis/internal/nowis/util"
	"nowis/pkg/configs"
	"nowis/pkg/interceptors"
	nowispb "nowis/protobuf/generated/nowis"

	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type NowisService struct {
	nowispb.NowisServiceServer
	repo *nowisrepo.NowisRepository
}

func NewNowisService(repo *nowisrepo.NowisRepository) NowisService {
	return NowisService{
		repo: repo,
	}
}

func (h NowisService) GetPostById(ctx context.Context, request *nowispb.GetPostByIdRequest) (*nowispb.GetPostByIdResponse, error) {
	locale := request.Locale.GetLang()
	id, err := uuid.Parse(request.Id)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid post ID format: %v", err)
	}

	post, err := h.repo.GetPostById(ctx, id, locale)
	if err != nil {
		// Log the error for internal debugging
		return nil, status.Errorf(codes.Internal, "failed to retrieve post: %v", err)
	}

	if post == nil {
		return nil, status.Errorf(codes.NotFound, "post with ID %s not found", request.Id)
	}

	return &nowispb.GetPostByIdResponse{
		Post: post.ToPBPost(),
	}, nil
}

func (h NowisService) GetPostBySlug(ctx context.Context, request *nowispb.GetPostBySlugRequest) (*nowispb.GetPostBySlugResponse, error) {
	locale := request.Locale.GetLang()
	slug := request.Slug

	post, err := h.repo.GetPostBySlug(ctx, slug, locale)
	if err != nil {
		return nil, err
	}

	return &nowispb.GetPostBySlugResponse{
		Post: post.ToPBPost(),
	}, nil
}

func (h NowisService) GetPosts(ctx context.Context, request *nowispb.GetPostsRequest) (*nowispb.GetPostsResponse, error) {
	locale := request.Locale.GetLang()
	page := int(request.GetPage())
	limit := int(request.GetLimit())
	searchQuery := request.GetSearchQuery()

	posts, err := h.repo.GetPosts(ctx, locale, page, limit, searchQuery)
	if err != nil {
		return nil, err
	}

	var pbPosts []*nowispb.Post

	for _, post := range posts {
		pbPosts = append(pbPosts, post.ToPBPost())
	}

	return &nowispb.GetPostsResponse{
		Posts: pbPosts,
	}, nil
}

// GetSidebarPostsByTags fetches all published and public posts, grouped by their tags.
func (h NowisService) GetSidebarPostsByTags(ctx context.Context, request *nowispb.GetSidebarPostsByTagsRequest) (*nowispb.GetSidebarPostsByTagsResponse, error) {
	repoTags, err := h.repo.GetSidebarPostsByTags(ctx, request.GetTagNameFilter())
	if err != nil {
		return nil, err
	}

	pbTags := make([]*nowispb.TagSidebar, len(repoTags))
	for i, tag := range repoTags {
		pbTags[i] = tag.ToPBTagSidebar()
	}

	return &nowispb.GetSidebarPostsByTagsResponse{
		Tags: pbTags,
	}, nil
}

func (h NowisService) GetPostComments(ctx context.Context, request *nowispb.GetPostCommentsRequest) (*nowispb.GetPostCommentsResponse, error) {
	postID, err := uuid.Parse(request.GetPostId())
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid post ID format: %v", err)
	}

	page := int(request.GetPage())
	limit := int(request.GetLimit())

	comments, err := h.repo.GetPostComments(ctx, postID, page, limit)
	if err != nil {
		return nil, err
	}

	pbComments := []*nowispb.Comment{}
	for _, comment := range comments {
		pbComments = append(pbComments, comment.ToPBComment())
	}

	return &nowispb.GetPostCommentsResponse{
		Comments: pbComments,
	}, nil
}

func (h NowisService) CreateComment(ctx context.Context, request *nowispb.CreateCommentRequest) (*nowispb.CreateCommentResponse, error) {
	postID, err := uuid.Parse(request.GetPostId())
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid post ID format: %v", err)
	}

	content := strings.TrimSpace(request.GetContent())
	if content == "" {
		return nil, status.Errorf(codes.InvalidArgument, "comment content cannot be empty")
	}

	animal := request.GetAnimal()
	if !util.IsValidEnumValue(animal, util.AllowedAnimalTypes) {
		return nil, status.Errorf(codes.InvalidArgument, "invalid animal type: %s", animal)
	}

	backgroundColor := request.GetBackgroundColor()
	if !util.IsValidEnumValue(backgroundColor, util.AllowedBackgroundColorTypes) {
		return nil, status.Errorf(codes.InvalidArgument, "invalid background color type: %s", backgroundColor)
	}

	comment, err := h.repo.CreateComment(ctx, postID, request.Content, request.Animal, request.BackgroundColor)
	if err != nil {
		return nil, err
	}

	return &nowispb.CreateCommentResponse{
		Comment: comment.ToPBComment(),
	}, nil
}

func (h NowisService) CreatePost(ctx context.Context, request *nowispb.CreatePostRequest) (*nowispb.CreatePostResponse, error) {
	userIDVal := ctx.Value(interceptors.UserIDKey)
	if userIDVal == nil {
		return nil, status.Errorf(codes.Unauthenticated, "user not authenticated")
	}
	userIDStr, ok := userIDVal.(string)
	if !ok {
		return nil, status.Errorf(codes.Internal, "invalid user ID type in context")
	}
	authorID, err := uuid.Parse(userIDStr)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "invalid user ID format: %v", err)
	}

	title := strings.TrimSpace(request.GetTitle())
	if title == "" {
		return nil, status.Errorf(codes.InvalidArgument, "title cannot be empty")
	}

	slug := generateSlug(title)
	// TODO: Handle slug collision (append random suffix or check DB)

	statusVal := model.PostStatusDraft
	switch request.GetStatus() {
	case nowispb.PostStatus_published:
		statusVal = model.PostStatusPublished
	case nowispb.PostStatus_archived:
		statusVal = model.PostStatusArchived
	}

	visibilityVal := model.PostVisibilityPrivate
	switch request.GetVisibility() {
	case nowispb.PostVisibility_public:
		visibilityVal = model.PostVisibilityPublic
	case nowispb.PostVisibility_unlisted:
		visibilityVal = model.PostVisibilityUnlisted
	}

	post := &model.Post{
		Title:            title,
		Slug:             slug,
		Content:          request.GetContent(),
		Summary:          request.GetSummary(),
		FeaturedImageURL: nil,
		AuthorID:         authorID,
		Status:           statusVal,
		Visibility:       visibilityVal,
		Tags:             request.GetTags(),
		ReadTimeMinutes:  calculateReadTime(request.GetContent()),
	}

	if request.GetFeaturedImageUrl() != "" {
		url := request.GetFeaturedImageUrl()
		post.FeaturedImageURL = &url
	}

	createdPost, err := h.repo.CreatePost(ctx, post)
	if err != nil {
		return nil, err
	}

	return &nowispb.CreatePostResponse{
		Post: createdPost.ToPBPost(),
	}, nil
}

func generateSlug(title string) string {
	// Convert to lowercase
	slug := strings.ToLower(title)
	// Replace spaces with hyphens
	slug = strings.ReplaceAll(slug, " ", "-")
	// Remove non-alphanumeric characters (except hyphens)
	reg, _ := regexp.Compile("[^a-z0-9-]+")
	slug = reg.ReplaceAllString(slug, "")
	// Trim hyphens
	slug = strings.Trim(slug, "-")
	return slug
}

func calculateReadTime(content string) int {
	wordsPerMinute := 200
	words := strings.Fields(content)
	if len(words) == 0 {
		return 0
	}
	return int(math.Ceil(float64(len(words)) / float64(wordsPerMinute)))
}

// HealthCheck returns the encryption passphrase and static salt hex.
func (h NowisService) HealthCheck(ctx context.Context, request *nowispb.HealthCheckRequest) (*nowispb.HealthCheckResponse, error) {
	config := configs.GetConfig()
	return &nowispb.HealthCheckResponse{
		AppId:         config.NowisEncryptionPassphrase,
		AppVersionRef: config.NowisEncryptionStaticSaltHex,
	}, nil
}
