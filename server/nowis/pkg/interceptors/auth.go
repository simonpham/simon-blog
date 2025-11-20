package interceptors

import (
	"context"
	"nowis/pkg/utils"

	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/auth"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type contextKey string

const UserIDKey contextKey = "userID"

func AuthInterceptor(ctx context.Context) (context.Context, error) {
	token, err := auth.AuthFromMD(ctx, "bearer")
	if err != nil {
		return nil, err
	}

	userID, err := utils.VerifyJwt(token)
	if err != nil {
		return nil, status.Errorf(codes.Unauthenticated, "invalid auth token: %v", err)
	}

	return context.WithValue(ctx, UserIDKey, userID), nil
}
