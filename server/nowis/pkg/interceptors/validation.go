package interceptors

import (
	"context"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func ValidationInterceptor(
	ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler,
) (any, error) {
	// Call the Validate method on the request message
	if v, ok := req.(interface{ Validate() error }); ok {
		if err := v.Validate(); err != nil {
			// Respond with the error code and message
			return nil, status.Errorf(codes.InvalidArgument, "%s", err.Error())
		}
	}
	// Call the handler function to process the request
	return handler(ctx, req)
}
