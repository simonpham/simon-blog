package utils

import (
	"fmt"
)

// WrapError is a utility function to wrap an error with additional context.
// It returns a new error that includes the original error and a message.
func WrapError(message string, err error) error {
	if err == nil {
		return fmt.Errorf("error wrapping operation failed, received nil error with message: %s", message)
	}
	return fmt.Errorf("%s: %w", message, err)
}
