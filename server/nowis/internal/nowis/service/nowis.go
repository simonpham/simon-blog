package service

import (
	"context"
	nowisrepo "nowis/internal/nowis/repository"
	nowispb "nowis/protobuf/generated/nowis"

	"github.com/google/uuid"
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
		return nil, err
	}

	post, err := h.repo.GetPostById(ctx, id, locale)
	if err != nil {
		return nil, err
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

	posts, err := h.repo.GetPosts(ctx, locale, page, limit)
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
