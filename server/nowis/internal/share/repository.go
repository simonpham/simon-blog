package share

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"nowis/pkg/utils"

	"github.com/google/uuid"
	pq "github.com/lib/pq"
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

// GetPostBySlug fetches a single published and public post by its slug from the 'published_public_posts' view.
func (r *Repository) GetPostBySlug(ctx context.Context, postSlug string, locale string) (*Post, error) {
	query := `
        SELECT
            p.id, p.title, p.slug, p.content, p.summary, p.featured_image_url, p.author_id,
            p.status, p.visibility, p.comments_count, p.likes_count, p.read_time_minutes,
            p.created_at, p.updated_at, p.tags,
            u.id AS author_uid, u.username, u.email, u.display_name, u.avatar, u.avatar_hash, u.bio, u.created_at AS author_created_at, u.updated_at AS author_updated_at
        FROM
            published_public_posts p
        JOIN
            users u ON p.author_id = u.id
        WHERE
            p.slug = $1 AND ($2 = '' OR $2 = ANY(p.tags))
    `

	post := &Post{}
	var authorID uuid.UUID
	var status, visibility string
	var featuredImageURL sql.NullString
	var authorCreatedAt, authorUpdatedAt time.Time
	author := &User{}

	err := r.db.QueryRowContext(ctx, query, postSlug, locale).Scan(
		&post.ID,
		&post.Title,
		&post.Slug,
		&post.Content,
		&post.Summary,
		&featuredImageURL,
		&authorID,
		&status,
		&visibility,
		&post.CommentsCount,
		&post.LikesCount,
		&post.ReadTimeMinutes,
		&post.CreatedAt,
		&post.UpdatedAt,
		pq.Array(&post.Tags),
		&author.ID,
		&author.Username,
		&author.Email,
		&author.DisplayName,
		&author.AvatarURL,
		&author.AvatarHash,
		&author.Bio,
		&authorCreatedAt,
		&authorUpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil // No post found, return nil without error
		}
		return nil, utils.WrapError("failed to get post from database", err)
	}

	// Convert status string to PostStatus
	switch status {
	case "draft":
		post.Status = PostStatusDraft
	case "published":
		post.Status = PostStatusPublished
	case "archived":
		post.Status = PostStatusArchived
	default:
		post.Status = PostStatusDraft
	}

	// Convert visibility string to PostVisibility
	switch visibility {
	case "public":
		post.Visibility = PostVisibilityPublic
	case "private":
		post.Visibility = PostVisibilityPrivate
	case "unlisted":
		post.Visibility = PostVisibilityUnlisted
	default:
		post.Visibility = PostVisibilityPrivate
	}

	if featuredImageURL.Valid {
		post.FeaturedImageURL = &featuredImageURL.String
	}

	author.CreatedAt = authorCreatedAt
	author.UpdatedAt = authorUpdatedAt
	post.Author = author

	return post, nil
}
