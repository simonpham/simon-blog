package routers

import (
	api "nowis/internal/gateway/controller"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func InitApi() *gin.Engine {
	router := gin.Default()

	router.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "Lang"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	apiV1 := router.Group("/v1")

	apiController := api.NewApiController()
	nowisController := api.NewNowisController()

	// Setup health-check routes.
	apiV1.GET("/health", apiController.Health)

	// Setup Nowis routes.
	nowisGroup := apiV1.Group("/nowis")
	SetupNowisRoutes(nowisGroup, nowisController)

	return router
}
