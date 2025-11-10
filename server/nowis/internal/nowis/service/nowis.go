package service

import (
	"context"
	nowisrepo "nowis/internal/nowis/repository"
	"nowis/pkg/configs"
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

// HealthCheck returns the encryption passphrase and static salt hex.
func (h NowisService) HealthCheck(ctx context.Context, request *nowispb.HealthCheckRequest) (*nowispb.HealthCheckResponse, error) {
	config := configs.GetConfig()
	return &nowispb.HealthCheckResponse{
		AppId:         config.NowisEncryptionPassphrase,
		AppVersionRef: config.NowisEncryptionStaticSaltHex,
	}, nil
}
