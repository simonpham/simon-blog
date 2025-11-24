package model

import (
	"fmt"
	"time"

	"nowis/internal/nowis/util"
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

// Post represents a blog post model as stored in the database.
type Post struct {
	ID               uuid.UUID      `db:"id" json:"id"`
	Title            string         `db:"title" json:"title"`
	Slug             string         `db:"slug" json:"slug"`
	Content          string         `db:"content" json:"content"`
	Summary          string         `db:"summary" json:"summary"`
	FeaturedImageURL *string        `db:"featured_image_url" json:"featuredImageUrl,omitempty"`
	AuthorID         uuid.UUID      `db:"author_id" json:"authorId"`
	Author           *User          `db:"-" json:"author,omitempty"` // Populated via JOIN
	Status           PostStatus     `db:"status" json:"status"`
	Visibility       PostVisibility `db:"visibility" json:"visibility"`
	CommentsCount    int            `db:"comments_count" json:"commentsCount"`
	LikesCount       int            `db:"likes_count" json:"likesCount"`
	ReadTimeMinutes  int            `db:"read_time_minutes" json:"readTimeMinutes"`
	CreatedAt        time.Time      `db:"created_at" json:"createdAt"`
	UpdatedAt        time.Time      `db:"updated_at" json:"updatedAt"`
	Tags             []string       `db:"tags" json:"tags"`
}

// ToPBPost converts a model.Post to a nowispb.Post, encrypting the Content
// and embedding the IV length, IV, and encryption timestamp within the content field itself,
// then Base64 URL-encoding it.
// The `content` field will now carry the Base64 URL-encoded combined payload.
func (p *Post) ToPBPost() *nowis.Post {
	var status nowis.PostStatus
	var visibility nowis.PostVisibility

	switch p.Status {
	case "draft":
		status = nowis.PostStatus_draft
	case "published":
		status = nowis.PostStatus_published
	case "archived":
		status = nowis.PostStatus_archived
	}

	switch p.Visibility {
	case "public":
		visibility = nowis.PostVisibility_public
	case "private":
		visibility = nowis.PostVisibility_private
	case "unlisted":
		visibility = nowis.PostVisibility_unlisted
	}

	// Encrypt the content just before sending. The returned `encodedPayload` is a
	// Base64 URL-encoded string containing IV length, IV, timestamp, and encrypted content.
	encodedPayload, err := util.EncryptContent(p.Content)
	if err != nil {
		// Handle this error appropriately in a real application.
		// For now, log the error and send the original plaintext content
		// (which means it won't be decrypted by the client, acting as an error indicator
		// if the client tries to decrypt it).
		fmt.Printf("Failed to encrypt post content for ID %s: %v\n", p.ID.String(), err)
		encodedPayload = p.Content // Fallback to sending plaintext (not ideal for obfuscation)
	}

	var authorPB *nowis.User
	if p.Author != nil {
		authorPB = p.Author.ToPBUser()
	}

	pbPost := &nowis.Post{
		Id:      p.ID.String(),
		Title:   p.Title,
		Slug:    p.Slug,
		Content: encodedPayload,
		Summary: p.Summary,
		FeaturedImageUrl: func() string {
			if p.FeaturedImageURL != nil {
				return *p.FeaturedImageURL
			}
			return ""
		}(),
		Author:          authorPB,
		Status:          status,
		Visibility:      visibility,
		CommentsCount:   int32(p.CommentsCount),
		LikesCount:      int32(p.LikesCount),
		ReadTimeMinutes: int32(p.ReadTimeMinutes),
		CreatedAt:       p.CreatedAt.Unix(),
		UpdatedAt:       p.UpdatedAt.Unix(),
		Tags:            p.Tags,
	}

	return pbPost
}
