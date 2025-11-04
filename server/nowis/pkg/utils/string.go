package utils

import "math/rand"

// RandomChar returns a random lowercase letter.
func RandomChar() string {
	return string(rune(97 + rand.Intn(26)))
}
