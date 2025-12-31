package main

import (
	"log"
	"os"

	"nowis/internal/share"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	handler := share.NewHandler()

	// Register route
	// The service will be deployed at share.sofluffy.io, so we can root it at /s/:slug or just use the same path structure.
	// User said "move server/nowis /s/:slug endpoint... so I can use https://share.sofluffy.io/s/:slug"
	// So route path is /s/:slug
	r.GET("/s/:slug", handler.GetPostSummaryPageBySlug)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8086"
	}

	log.Printf("Share service starting on port %s...", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
