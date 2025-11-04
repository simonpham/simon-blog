package network

import (
	"context"
	"testing"
)

func TestCreateGrpcClientConnection(t *testing.T) {
	// Test valid connection.
	conn, err := CreateGrpcClientConnection(context.Background(), "localhost:50051")
	if err != nil {
		t.Error(err)
	}
	if conn == nil {
		t.Error("connection is nil")
	}

	// Test invalid connection.
	conn, err = CreateGrpcClientConnection(context.Background(), "localhost:50052")
	if err == nil {
		t.Error("invalid connection should return error")
	}
	if conn != nil {
		t.Error("connection should be nil")
	}
}
