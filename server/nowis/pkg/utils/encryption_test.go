package utils

import "testing"

func TestEncryptPassword(t *testing.T) {
	password := "password"
	hashedPassword, err := EncryptPassword(password)
	if err != nil {
		t.Error(err)
	}
	if len(hashedPassword) == 0 {
		t.Error("hashed password is empty")
	}
}

func TestComparePassword(t *testing.T) {
	password := "password"
	hashedPassword, err := EncryptPassword(password)
	if err != nil {
		t.Error(err)
	}
	err = ComparePassword(password, hashedPassword)
	if err != nil {
		t.Error(err)
	}
}
