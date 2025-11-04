package utils

import "testing"

func TestValidateEmail(t *testing.T) {
	// Test valid email.
	email := "simon@sofluffy.io"
	err := ValidateEmail(email)
	if err != nil {
		t.Error(err)
	}

	// Test invalid email.
	email = "simon@sofluffy"
	err = ValidateEmail(email)
	if err == nil {
		t.Error("invalid email should return error")
	}

	// Test empty email.
	email = ""
	err = ValidateEmail(email)
	if err == nil {
		t.Error("empty email should return error")
	}

	// Test email with spaces.
	email = "simon sofluffy"
	err = ValidateEmail(email)
	if err == nil {
		t.Error("email with spaces should return error")
	}

	// Test email with special characters.
	email = "simon#@??sofluffy.io"
	err = ValidateEmail(email)
	if err == nil {
		t.Error("email with special characters should return error")
	}
}
