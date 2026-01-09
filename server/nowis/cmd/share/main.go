package main

import (
	"log"

	"nowis/internal/share"
	"nowis/pkg/configs"
	"nowis/pkg/db"

	"github.com/gin-gonic/gin"
)

func main() {
	config := configs.GetConfig()

	// Initialize database connection
	authDb, err := db.OpenAuthDatabase()
	if err != nil {
		log.Fatalf("[Share] Error opening database: %v", err)
	}
	defer authDb.Close()

	// Initialize repository and handler
	repo := share.NewRepository(authDb)
	handler := share.NewHandler(repo)

	r := gin.Default()

	// Health check endpoint
	r.GET("/api/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Register route
	r.GET("/s/:slug", handler.GetPostSummaryPageBySlug)

	if err := r.Run(config.ShareInternalAddress); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
