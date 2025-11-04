package utils

import (
	"errors"
	"golang.org/x/crypto/bcrypt"
)

func EncryptPassword(password string) ([]byte, error) {
	var _password = []byte(password)

	hashedPassword, err := bcrypt.GenerateFromPassword(_password, bcrypt.DefaultCost)
	if err != nil {
		return nil, errors.New("internal server error")
	}

	return hashedPassword, nil
}

func ComparePassword(password string, hashedPassword []byte) error {
	var _password = []byte(password)

	err := bcrypt.CompareHashAndPassword(hashedPassword, _password)
	if err != nil {
		return errors.New("password is invalid")
	}

	return nil
}
