package repository

import (
	"context"
	"database/sql"
	"errors"

	"nowis/internal/nowis/model"
	"nowis/pkg/utils"

	"github.com/google/uuid"
	pq "github.com/lib/pq"
)

type NowisRepositoryHandler interface {
	GetPostById(ctx context.Context, postId uuid.UUID, locale string) (*model.Post, error)
	GetPostBySlug(ctx context.Context, postSlug string, locale string) (*model.Post, error)
	GetPosts(ctx context.Context, locale string, page, limit int) ([]model.Post, error)
	GetSidebarPostsByTags(ctx context.Context) ([]model.TagSidebar, error)
}

type NowisRepository struct {
	NowisRepositoryHandler
	db *sql.DB
}

func NewNowisRepository(db *sql.DB) *NowisRepository {
	return &NowisRepository{db: db}
}

// GetPost fetches a single published and public post by its ID from the 'published_public_posts' view.
// It also aggregates and returns the tags associated with the post.
func (r *NowisRepository) GetPostById(ctx context.Context, postID uuid.UUID, locale string) (*model.Post, error) {
	query := `
        SELECT
            id, title, slug, content, summary, featured_image_url, author_id,
            status, visibility, comments_count, likes_count, read_time_minutes,
            created_at, updated_at, tags
        FROM
            published_public_posts
        WHERE
            id = $1 AND ($2 = '' OR $2 = ANY(tags))
    `

	post := &model.Post{}

	err := r.db.QueryRowContext(ctx, query, postID, locale).Scan(
		&post.ID,
		&post.Title,
		&post.Slug,
		&post.Content,
		&post.Summary,
		&post.FeaturedImageURL,
		&post.AuthorID,
		&post.Status,
		&post.Visibility,
		&post.CommentsCount,
		&post.LikesCount,
		&post.ReadTimeMinutes,
		&post.CreatedAt,
		&post.UpdatedAt,
		pq.Array(&post.Tags),
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil // No post found, return nil without error
		}
		return nil, utils.WrapError("failed to get post from database", err)
	}

	return post, nil
}

// GetPostBySlug fetches a single published and public post by its slug from the 'published_public_posts' view.
// It also aggregates and returns the tags associated with the post.
func (r *NowisRepository) GetPostBySlug(ctx context.Context, postSlug string, locale string) (*model.Post, error) {
	query := `
        SELECT
            id, title, slug, content, summary, featured_image_url, author_id,
            status, visibility, comments_count, likes_count, read_time_minutes,
            created_at, updated_at, tags
        FROM
            published_public_posts
        WHERE
            slug = $1 AND ($2 = '' OR $2 = ANY(tags))
    `

	post := &model.Post{}

	err := r.db.QueryRowContext(ctx, query, postSlug, locale).Scan(
		&post.ID,
		&post.Title,
		&post.Slug,
		&post.Content,
		&post.Summary,
		&post.FeaturedImageURL,
		&post.AuthorID,
		&post.Status,
		&post.Visibility,
		&post.CommentsCount,
		&post.LikesCount,
		&post.ReadTimeMinutes,
		&post.CreatedAt,
		&post.UpdatedAt,
		pq.Array(&post.Tags),
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil // No post found, return nil without error
		}
		return nil, utils.WrapError("failed to get post from database", err)
	}

	return post, nil
}

// GetPosts fetches a list of published and public posts with pagination and optional locale filtering by tag.
// page is 1-indexed.
// If locale is empty, all posts (matching visibility/status) are returned without tag filtering.
func (r *NowisRepository) GetPosts(ctx context.Context, locale string, page int, limit int) ([]model.Post, error) {
	if page < 1 {
		page = 1
	}
	offset := (page - 1) * limit

	if limit < 1 {
		limit = 10 // Or any sensible default, or return an error
	}

	// SQL Query to select posts, including aggregated tags and filtering by locale tag.
	// The `EXISTS` subquery efficiently filters posts that have a tag matching the locale,
	// without introducing duplicate rows if a post has multiple tags.
	query := `
        SELECT
            p.id, p.title, p.slug, p.content, p.summary, p.featured_image_url, p.author_id,
            p.status, p.visibility, p.comments_count, p.likes_count, p.read_time_minutes,
            p.created_at, p.updated_at,
            p.tags
        FROM
            published_public_posts p
        WHERE
            ($3 = '' OR $3 = ANY(p.tags))
        ORDER BY
            p.created_at DESC
        OFFSET $1
        LIMIT $2
    `
	// Parameters: $1 = offset, $2 = limit, $3 = locale

	rows, err := r.db.QueryContext(ctx, query, offset, limit, locale)
	if err != nil {
		return nil, utils.WrapError("failed to query posts from database", err)
	}
	defer rows.Close()

	var posts []model.Post
	for rows.Next() {
		post := model.Post{}
		err := rows.Scan(
			&post.ID,
			&post.Title,
			&post.Slug,
			&post.Content,
			&post.Summary,
			&post.FeaturedImageURL,
			&post.AuthorID,
			&post.Status,
			&post.Visibility,
			&post.CommentsCount,
			&post.LikesCount,
			&post.ReadTimeMinutes,
			&post.CreatedAt,
			&post.UpdatedAt,
			pq.Array(&post.Tags),
		)
		if err != nil {
			return nil, utils.WrapError("failed to scan post row", err)
		}
		posts = append(posts, post)
	}

	if err = rows.Err(); err != nil {
		return nil, utils.WrapError("error after iterating rows", err)
	}

	return posts, nil
}

// GetSidebarPostsByTags fetches all published and public posts, grouped by their tags.
func (r *NowisRepository) GetSidebarPostsByTags(ctx context.Context) ([]model.TagSidebar, error) {
	query := `
        SELECT
            t.name AS tag_name,
            p.id AS post_id,
            p.title AS post_title,
            p.slug AS post_slug
        FROM
            tags t
        JOIN
            post_tags pt ON t.id = pt.tag_id
        JOIN
            published_public_posts p ON pt.post_id = p.id
        ORDER BY
            t.name, p.title;
    `

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, utils.WrapError("failed to query sidebar posts by tags from database", err)
	}
	defer rows.Close()

	// Use a map to build the hierarchical structure: tagName -> list of posts
	tagMap := make(map[string][]model.SidebarPost)

	for rows.Next() {
		var tagName string
		var postID uuid.UUID
		var postTitle string
		var postSlug string

		err := rows.Scan(&tagName, &postID, &postTitle, &postSlug)
		if err != nil {
			return nil, utils.WrapError("failed to scan sidebar post row", err)
		}

		tagMap[tagName] = append(tagMap[tagName], model.SidebarPost{
			ID:    postID,
			Title: postTitle,
			Slug:  postSlug,
		})
	}

	if err = rows.Err(); err != nil {
		return nil, utils.WrapError("error after iterating rows", err)
	}

	var sidebar []model.TagSidebar
	// Iterate through the map to create the slice of TagSidebar.
	// The order of tags in the slice will depend on map iteration, which is not guaranteed.
	// Sorting can be applied at a higher layer (e.g., service or presentation).
	for tagName, posts := range tagMap {
		sidebar = append(sidebar, model.TagSidebar{
			TagName: tagName,
			Posts:   posts,
		})
	}

	return sidebar, nil
}
