package model

import (
	"time"

	nowispb "nowis/protobuf/generated/nowis"

	"github.com/google/uuid"
)

type Comment struct {
	ID              uuid.UUID `json:"id"`
	PostID          uuid.UUID `json:"post_id"`
	Animal          string    `json:"animal"`
	BackgroundColor string    `json:"background_color"`
	Content         string    `json:"content"`
	CreatedAt       time.Time `json:"created_at"`
}

func FromPBComment(pbComment *nowispb.Comment) *Comment {
	return &Comment{
		ID:              uuid.MustParse(pbComment.Id),
		PostID:          uuid.MustParse(pbComment.PostId),
		Animal:          pbComment.Animal,
		BackgroundColor: pbComment.BackgroundColor,
		Content:         pbComment.Content,
		CreatedAt:       time.Unix(pbComment.CreatedAt, 0),
	}
}

func (ts *Comment) ToGinMap() map[string]interface{} {
	return map[string]interface{}{
		"id":               ts.ID.String(),
		"post_id":          ts.PostID.String(),
		"animal":           ts.Animal,
		"background_color": ts.BackgroundColor,
		"content":          ts.Content,
		"created_at":       ts.CreatedAt,
	}
}
