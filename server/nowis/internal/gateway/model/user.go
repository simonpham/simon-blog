package model

import (
	"time"

	"nowis/protobuf/generated/nowis"

	"github.com/google/uuid"
)

type User struct {
	ID          uuid.UUID `json:"id"`
	Username    string    `json:"username"`
	Email       string    `json:"email"`
	DisplayName string    `json:"displayName"`
	AvatarURL   string    `json:"avatarUrl"`
	AvatarHash  string    `json:"avatarHash"`
	Bio         string    `json:"bio"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

func FromPBUser(pbUser *nowis.User) (*User, error) {
	userID, err := uuid.Parse(pbUser.Id)
	if err != nil {
		return nil, err
	}

	return &User{
		ID:          userID,
		Username:    pbUser.Username,
		Email:       pbUser.Email,
		DisplayName: pbUser.DisplayName,
		AvatarURL:   pbUser.AvatarUrl,
		AvatarHash:  pbUser.AvatarHash,
		Bio:         pbUser.Bio,
		CreatedAt:   time.Unix(pbUser.CreatedAt, 0),
		UpdatedAt:   time.Unix(pbUser.UpdatedAt, 0),
	}, nil
}
