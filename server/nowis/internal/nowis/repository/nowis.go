package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"nowis/internal/nowis/model"
	"nowis/pkg/utils"

	"github.com/google/uuid"
	pq "github.com/lib/pq"
)

type NowisRepositoryHandler interface {
	GetPostById(ctx context.Context, postId uuid.UUID, locale string) (*model.Post, error)
	GetPostBySlug(ctx context.Context, postSlug string, locale string) (*model.Post, error)
	GetPosts(ctx context.Context, locale string, page, limit int, searchQuery string) ([]model.Post, error)
	GetSidebarPostsByTags(ctx context.Context, tagNameFilter string) ([]model.TagSidebar, error)
	GetPostComments(ctx context.Context, postId uuid.UUID, page int, limit int) ([]model.Comment, error)
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
func (r *NowisRepository) GetPosts(ctx context.Context, locale string, page int, limit int, searchQuery string) ([]model.Post, error) {
	if page < 1 {
		page = 1
	}
	offset := (page - 1) * limit

	if limit < 1 {
		limit = 10
	}

	var (
		selectColumns []string
		whereClauses  []string
		args          []any
		paramIndex    = 1
	)

	// Base columns
	selectColumns = []string{
		"p.id",
		"p.title",
		"p.slug",
		"p.content",
		"p.summary",
		"p.featured_image_url",
		"p.author_id",
		"p.status",
		"p.visibility",
		"p.comments_count",
		"p.likes_count",
		"p.read_time_minutes",
		"p.created_at",
		"p.updated_at",
		"p.tags",
	}

	orderByClause := " ORDER BY p.created_at DESC " // Default order

	// Add full-text search condition if searchQuery is provided
	if searchQuery != "" {
		// Use websearch_to_tsquery for better user experience (handles multiple words, quoted phrases, etc.)
		selectColumns = append(selectColumns, "ts_rank(p.search_vector, websearch_to_tsquery('english', $"+strconv.Itoa(paramIndex)+")) AS rank_score")
		whereClauses = append(whereClauses, "p.search_vector @@ websearch_to_tsquery('english', $"+strconv.Itoa(paramIndex)+")")
		args = append(args, searchQuery)
		paramIndex++
		orderByClause = " ORDER BY rank_score DESC, p.created_at DESC " // Prioritize rank, then date
	} else {
		// If no search query, still select a dummy rank_score to keep the SCAN statement consistent
		selectColumns = append(selectColumns, "0.0 AS rank_score")
	}

	// Add locale filtering by tag
	whereClauses = append(whereClauses, "($"+strconv.Itoa(paramIndex)+" = '' OR $"+strconv.Itoa(paramIndex)+" = ANY(p.tags))")
	args = append(args, locale)
	paramIndex++

	// Construct the WHERE clause
	whereClause := ""
	if len(whereClauses) > 0 {
		whereClause = " WHERE " + strings.Join(whereClauses, " AND ")
	}

	// Add pagination parameters
	offsetClause := " OFFSET $" + strconv.Itoa(paramIndex)
	args = append(args, offset)
	paramIndex++

	limitClause := " LIMIT $" + strconv.Itoa(paramIndex)
	args = append(args, limit)
	paramIndex++

	// Assemble the final query
	query := fmt.Sprintf(`
        SELECT
            %s
        FROM
            published_public_posts p
        %s
        %s
        %s
        %s
    `,
		strings.Join(selectColumns, ", "),
		whereClause,
		orderByClause,
		offsetClause,
		limitClause,
	)

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, utils.WrapError("failed to query posts from database", err)
	}
	defer rows.Close()

	var posts []model.Post
	for rows.Next() {
		post := model.Post{}
		var rankScore float64 // Variable to hold the rank score
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
			&rankScore, // Scan the rank score
		)
		if err != nil {
			return nil, utils.WrapError("failed to scan post row", err)
		}
		// You might want to store rankScore in the model.Post if it's relevant for the client,
		// but for now, we just scan it to keep the row.Scan consistent.
		posts = append(posts, post)
	}

	if err = rows.Err(); err != nil {
		return nil, utils.WrapError("error after iterating rows", err)
	}

	return posts, nil
}

// GetSidebarPostsByTags fetches all published and public posts, grouped by their tags, with an optional tag name filter.
// If tagNameFilter is empty, all tags and their posts are returned.
func (r *NowisRepository) GetSidebarPostsByTags(ctx context.Context, tagNameFilter string) ([]model.TagSidebar, error) {
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
        WHERE
            ($1 = '' OR t.name = $1)
        ORDER BY
            t.name, p.title;
    `

	rows, err := r.db.QueryContext(ctx, query, tagNameFilter)
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

func (r *NowisRepository) GetPostComments(ctx context.Context, postID uuid.UUID, page int, limit int) ([]model.Comment, error) {
	if page < 1 {
		page = 1
	}
	offset := (page - 1) * limit

	if limit < 1 {
		limit = 10
	}

	query := `
        SELECT
            id,
            post_id,
            animal,
            background_color,
            content,
            created_at
        FROM
            comments
        WHERE
            post_id = $1
        ORDER BY
            created_at DESC
        LIMIT $2 OFFSET $3;
    `

	rows, err := r.db.QueryContext(ctx, query, postID, limit, offset)
	if err != nil {
		return nil, utils.WrapError("failed to query post comments from database", err)
	}
	defer rows.Close()

	var comments []model.Comment
	for rows.Next() {
		var comment model.Comment

		err := rows.Scan(&comment.ID, &comment.PostID, &comment.Animal, &comment.BackgroundColor, &comment.Content, &comment.CreatedAt)
		if err != nil {
			return nil, utils.WrapError("failed to scan post comment row", err)
		}

		comments = append(comments, comment)
	}

	if err = rows.Err(); err != nil {
		return nil, utils.WrapError("error after iterating rows", err)
	}

	return comments, nil
}
