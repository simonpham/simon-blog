package utils

import (
	"github.com/golang-jwt/jwt/v4"
	"nowis/pkg/configs"
	"time"
)

type Tokens struct {
	Token        string
	RefreshToken string
}

// GenerateJwt generates an access and refresh token for a user.
func GenerateJwt(userId int) (Tokens, error) {
	config := configs.GetConfig()
	token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": userId,
		"exp": time.Now().Add(time.Duration(config.AuthTokenExpiration) * time.Hour).Unix(),
	}).SignedString([]byte(config.AuthTokenSigningKey))
	if err != nil {
		return Tokens{}, err
	}
	refreshToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": userId,
		"exp": time.Now().Add(time.Duration(config.AuthTokenExpiration*10) * time.Hour).Unix(),
	}).SignedString([]byte(config.AuthTokenSigningKey))
	if err != nil {
		return Tokens{}, err
	}
	return Tokens{token, refreshToken}, nil
}

// VerifyJwt verifies a JWT token and returns the user id.
func VerifyJwt(token string) (int, error) {
	config := configs.GetConfig()
	claims := jwt.MapClaims{}
	_, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(config.AuthTokenSigningKey), nil
	})
	if err != nil {
		return 0, err
	}
	sub := claims["sub"].(float64)
	return int(sub), nil
}
