package model

import (
	nowispb "nowis/protobuf/generated/nowis"

	"github.com/google/uuid"
)

type User struct {
	ID          uuid.UUID
	Username    string
	Email       string
	DisplayName string
	AvatarURL   string
	AvatarHash  string
	Bio         string
	CreatedAt   int64
	UpdatedAt   int64
}

func (u *User) ToPBUser() *nowispb.User {
	return &nowispb.User{
		Id:          u.ID.String(),
		Username:    u.Username,
		Email:       u.Email,
		DisplayName: u.DisplayName,
		AvatarUrl:   u.AvatarURL,
		AvatarHash:  u.AvatarHash,
		Bio:         u.Bio,
		CreatedAt:   u.CreatedAt,
		UpdatedAt:   u.UpdatedAt,
	}
}
