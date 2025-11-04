package utils

import (
	"errors"
	"github.com/go-playground/validator/v10"
	"strings"
	"unicode"
	"unicode/utf8"
)

func ValidateEmail(email string) error {
	validate := validator.New()
	err := validate.Var(email, "required,email")

	if err != nil {
		return err
	}

	return nil
}

func ValidateUsername(username string) error {
	if utf8.ValidString(username) == false {
		return errors.New("username or email address is invalid")
	}

	if strings.TrimSpace(username) == "" {
		return errors.New("username or email address is required")
	}

	validate := validator.New()
	var err error
	if strings.Contains(username, "@") {
		err = validate.Var(username, "required,email")
	} else {
		if !isUsernameFormatValid(username) {
			return errors.New("username is invalid")
		}

		err = validate.Var(username, "required,min=7,max=50")
	}

	if err != nil {
		return err
	}

	return nil
}

func ValidatePassword(password string) error {
	if utf8.ValidString(password) == false {
		return errors.New("password is invalid")
	}

	if strings.TrimSpace(password) == "" {
		return errors.New("password is required")
	}

	validate := validator.New()
	err := validate.Var(password, "required,min=8,max=50")

	if err != nil {
		return err
	}

	return nil
}

func isUsernameFormatValid(input string) bool {
	// Check if first character is alphabetical
	if !unicode.IsLetter(rune(input[0])) {
		return false
	}

	// Check if input has consecutive underscores or dots
	for i := 0; i < len(input)-1; i++ {
		if (input[i] == '_' || input[i] == '.') && (input[i+1] == '_' || input[i+1] == '.') {
			return false
		}
	}

	// Check if last character is alphanumeric
	if !unicode.IsLetter(rune(input[len(input)-1])) && !unicode.IsDigit(rune(input[len(input)-1])) {
		return false
	}

	// Check if input contains only valid characters
	for _, c := range input {
		if !unicode.IsLetter(c) && !unicode.IsDigit(c) && c != '_' && c != '.' {
			return false
		}
	}

	return true
}
