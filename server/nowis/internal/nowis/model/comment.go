package model

import (
	"time"

	nowispb "nowis/protobuf/generated/nowis"

	"github.com/google/uuid"
)

type Comment struct {
	ID              uuid.UUID `db:"id" json:"id"`
	PostID          uuid.UUID `db:"post_id" json:"post_id"`
	Animal          string    `db:"animal" json:"animal"`
	BackgroundColor string    `db:"background_color" json:"background_color"`
	Content         string    `db:"content" json:"content"`
	CreatedAt       time.Time `db:"created_at" json:"createdAt"`
}

func (c *Comment) ToPBComment() *nowispb.Comment {
	return &nowispb.Comment{
		Id:              c.ID.String(),
		PostId:          c.PostID.String(),
		Animal:          c.Animal,
		BackgroundColor: c.BackgroundColor,
		Content:         c.Content,
		CreatedAt:       c.CreatedAt.Unix(),
	}
}
