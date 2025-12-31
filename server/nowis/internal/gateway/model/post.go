package model

import (
	"time"

	"nowis/protobuf/generated/nowis"

	"github.com/google/uuid"
)

type PostStatus string

const (
	PostStatusDraft     PostStatus = "draft"
	PostStatusPublished PostStatus = "published"
	PostStatusArchived  PostStatus = "archived"
)

type PostVisibility string

const (
	PostVisibilityPublic   PostVisibility = "public"
	PostVisibilityPrivate  PostVisibility = "private"
	PostVisibilityUnlisted PostVisibility = "unlisted"
)

type Post struct {
	ID               uuid.UUID      `json:"id"`
	Title            string         `json:"title"`
	Slug             string         `json:"slug"`
	Content          string         `json:"content"`
	Summary          string         `json:"summary"`
	FeaturedImageURL *string        `json:"featuredImageUrl,omitempty"`
	Author           *User          `json:"author"`
	Status           PostStatus     `json:"status"`
	Visibility       PostVisibility `json:"visibility"`
	CommentsCount    int32          `json:"commentsCount"`
	LikesCount       int32          `json:"likesCount"`
	ReadTimeMinutes  int32          `json:"readTimeMinutes"`
	CreatedAt        time.Time      `json:"createdAt"`
	UpdatedAt        time.Time      `json:"updatedAt"`
	Tags             []string       `json:"tags"`
}

func FromPBPost(pbPost *nowis.Post) (*Post, error) {
	var status PostStatus
	var visibility PostVisibility

	switch pbPost.Status {
	case nowis.PostStatus_draft:
		status = PostStatusDraft
	case nowis.PostStatus_published:
		status = PostStatusPublished
	case nowis.PostStatus_archived:
		status = PostStatusArchived
	default:
		status = PostStatusDraft
	}

	switch pbPost.Visibility {
	case nowis.PostVisibility_public:
		visibility = PostVisibilityPublic
	case nowis.PostVisibility_private:
		visibility = PostVisibilityPrivate
	case nowis.PostVisibility_unlisted:
		visibility = PostVisibilityUnlisted
	default:
		visibility = PostVisibilityPrivate
	}

	postID, err := uuid.Parse(pbPost.Id)
	if err != nil {
		return nil, err
	}

	var author *User
	if pbPost.Author != nil {
		author, err = FromPBUser(pbPost.Author)
		if err != nil {
			return nil, err
		}
	}

	var featuredImageURL *string
	if pbPost.FeaturedImageUrl != "" {
		url := pbPost.FeaturedImageUrl
		featuredImageURL = &url
	}

	return &Post{
		ID:               postID,
		Title:            pbPost.Title,
		Slug:             pbPost.Slug,
		Content:          pbPost.Content,
		Summary:          pbPost.Summary,
		FeaturedImageURL: featuredImageURL,
		Author:           author,
		Status:           status,
		Visibility:       visibility,
		CommentsCount:    pbPost.CommentsCount,
		LikesCount:       pbPost.LikesCount,
		ReadTimeMinutes:  pbPost.ReadTimeMinutes,
		CreatedAt:        time.Unix(pbPost.CreatedAt, 0),
		UpdatedAt:        time.Unix(pbPost.UpdatedAt, 0),
		Tags:             pbPost.Tags,
	}, nil
}

func (p *Post) ToGinMap() map[string]interface{} {
	return map[string]interface{}{
		"id":               p.ID.String(),
		"title":            p.Title,
		"slug":             p.Slug,
		"content":          p.Content,
		"summary":          p.Summary,
		"featuredImageUrl": p.FeaturedImageURL,
		"author":           p.Author,
		"status":           p.Status,
		"visibility":       p.Visibility,
		"commentsCount":    p.CommentsCount,
		"likesCount":       p.LikesCount,
		"readTimeMinutes":  p.ReadTimeMinutes,
		"createdAt":        p.CreatedAt,
		"updatedAt":        p.UpdatedAt,
		"tags":             p.Tags,
	}
}

type SummaryPost struct {
	ID               uuid.UUID `json:"id"`
	Title            string    `json:"title"`
	Slug             string    `json:"slug"`
	Summary          string    `json:"summary"`
	FeaturedImageURL *string   `json:"featuredImageUrl,omitempty"`
	Author           *User     `json:"author"`
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
	Tags             []string  `json:"tags"`
}

func (p *SummaryPost) ToGinMap() map[string]interface{} {
	return map[string]interface{}{
		"id":               p.ID.String(),
		"title":            p.Title,
		"slug":             p.Slug,
		"summary":          p.Summary,
		"featuredImageUrl": p.FeaturedImageURL,
		"author":           p.Author,
		"createdAt":        p.CreatedAt,
		"updatedAt":        p.UpdatedAt,
		"tags":             p.Tags,
	}
}

type CreatePostRequestBody struct {
	Title            string         `json:"title" binding:"required"`
	Content          string         `json:"content" binding:"required"`
	Summary          string         `json:"summary"`
	FeaturedImageURL string         `json:"featuredImageUrl"`
	Status           PostStatus     `json:"status"`
	Visibility       PostVisibility `json:"visibility"`
	Tags             []string       `json:"tags"`
}

type UpdatePostRequestBody struct {
	Title            string         `json:"title"`
	Content          string         `json:"content"`
	Summary          string         `json:"summary"`
	FeaturedImageURL string         `json:"featuredImageUrl"`
	Status           PostStatus     `json:"status"`
	Visibility       PostVisibility `json:"visibility"`
	Tags             []string       `json:"tags"`
}
