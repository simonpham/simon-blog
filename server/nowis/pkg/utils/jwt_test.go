package utils

import "testing"

func TestGenerateJwt(t *testing.T) {
	tokens, err := GenerateJwt("1")
	if err != nil {
		t.Error(err)
	}
	if len(tokens.Token) == 0 {
		t.Error("token is empty")
	}
	if len(tokens.RefreshToken) == 0 {
		t.Error("refresh token is empty")
	}
}

func TestVerifyJwt(t *testing.T) {
	tokens, err := GenerateJwt("1")
	if err != nil {
		t.Error(err)
	}
	userId, err := VerifyJwt(tokens.Token)
	if err != nil {
		t.Error(err)
	}
	if userId != "1" {
		t.Errorf("expected user id 1, got %s", userId)
	}
}
