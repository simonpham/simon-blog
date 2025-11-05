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
	locale := request.Locale.Lang
	page := int(request.Page)
	limit := int(request.Limit)

	posts, err := h.repo.GetPosts(ctx, locale, page, limit)
	if err != nil {
		return nil, err
	}

	var pbPosts []*nowispb.Post

	for _, post := range posts {
		var status nowispb.PostStatus
		var visibility nowispb.PostVisibility

		switch post.Status {
		case "draft":
			status = nowispb.PostStatus_draft
		case "published":
			status = nowispb.PostStatus_published
		case "archived":
			status = nowispb.PostStatus_archived
		}

		switch post.Visibility {
		case "public":
			visibility = nowispb.PostVisibility_public
		case "private":
			visibility = nowispb.PostVisibility_private
		case "unlisted":
			visibility = nowispb.PostVisibility_unlisted
		}

		pbPosts = append(pbPosts, &nowispb.Post{
			Id:               post.ID.String(),
			Title:            post.Title,
			Slug:             post.Slug,
			Content:          post.Content,
			Summary:          post.Summary,
			FeaturedImageUrl: *post.FeaturedImageURL,
			AuthorId:         post.AuthorID.String(),
			Status:           status,
			Visibility:       visibility,
			CommentsCount:    int32(post.CommentsCount),
			LikesCount:       int32(post.LikesCount),
			ReadTimeMinutes:  int32(post.ReadTimeMinutes),
			CreatedAt:        post.CreatedAt.Unix(),
			UpdatedAt:        post.UpdatedAt.Unix(),
			Tags:             post.Tags,
		})
	}

	return &nowispb.GetPostsResponse{
		Posts: pbPosts,
	}, nil
}
