package service

import (
	"context"
	nowisrepo "nowis/internal/nowis/repository"
	nowispb "nowis/protobuf/generated/nowis"
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
