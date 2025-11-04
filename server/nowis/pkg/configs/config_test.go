package configs

import (
	"os"
	"testing"
)

func TestGetConfig(t *testing.T) {
	config := GetConfig()

	// Test default config.
	if config.Env != "debug" {
		t.Error("Env should be debug")
	}

	// set config.Env in environment to "test" for the next test.
	err := os.Setenv("ENV", "test")
	if err != nil {
		return
	}

	// Test invalid config.
	config = GetConfig()
	if config.Env != "test" {
		t.Error("Env should be test")
	}

	// reset config.Env in environment to "test2" for the next test.
	err = os.Setenv("ENV", "test2")
	if err != nil {
		return
	}

	// Test valid config.
	config = GetConfig()
	if config.Env != "test2" {
		t.Error("Env should be test2")
	}
}
