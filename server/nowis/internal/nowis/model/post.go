package model

import (
	"time"

	"github.com/google/uuid"
)

// PostStatus represents the status of a post, mapping to the PostgreSQL ENUM.
type PostStatus string

const (
	PostStatusDraft     PostStatus = "draft"
	PostStatusPublished PostStatus = "published"
	PostStatusArchived  PostStatus = "archived"
)

// PostVisibility represents the visibility of a post, mapping to the PostgreSQL ENUM.
type PostVisibility string

const (
	PostVisibilityPublic   PostVisibility = "public"
	PostVisibilityPrivate  PostVisibility = "private"
	PostVisibilityUnlisted PostVisibility = "unlisted"
)

// Post represents a blog post model as stored in the database.
type Post struct {
	ID               uuid.UUID      `db:"id" json:"id"`
	Title            string         `db:"title" json:"title"`
	Slug             string         `db:"slug" json:"slug"`
	Content          string         `db:"content" json:"content"`
	Summary          string         `db:"summary" json:"summary"`
	FeaturedImageURL *string        `db:"featured_image_url" json:"featuredImageUrl,omitempty"`
	AuthorID         uuid.UUID      `db:"author_id" json:"authorId"`
	Status           PostStatus     `db:"status" json:"status"`
	Visibility       PostVisibility `db:"visibility" json:"visibility"`
	CommentsCount    int            `db:"comments_count" json:"commentsCount"`
	LikesCount       int            `db:"likes_count" json:"likesCount"`
	ReadTimeMinutes  int            `db:"read_time_minutes" json:"readTimeMinutes"`
	CreatedAt        time.Time      `db:"created_at" json:"createdAt"`
	UpdatedAt        time.Time      `db:"updated_at" json:"updatedAt"`
	Tags             []string       `db:"tags" json:"tags"`
}
