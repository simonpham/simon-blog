package util

import "slices"

// Allowed values for animal_type
var AllowedAnimalTypes = []string{
	"rabbit", "cat", "dog", "bear", "panda",
	"sheep", "koala", "wolf", "fox", "chipmunk",
}

// Allowed values for background_color_type
var AllowedBackgroundColorTypes = []string{
	"red", "orange", "yellow", "green", "blue", "purple", "pink",
}

// isValidEnumValue checks if a string exists in a slice of allowed values.
func IsValidEnumValue(value string, allowedValues []string) bool {
	return slices.Contains(allowedValues, value)
}
