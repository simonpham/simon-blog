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
