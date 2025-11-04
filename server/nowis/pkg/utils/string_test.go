package utils

import "testing"

func TestRandomChar(t *testing.T) {
	randomChar := RandomChar()
	if len(randomChar) != 1 {
		t.Error("random char is not 1 character")
	}

	if randomChar < "a" || randomChar > "z" {
		t.Error("random char is not a lowercase letter")
	}
}
