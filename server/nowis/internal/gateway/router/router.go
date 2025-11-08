package routers

import (
	"github.com/gin-gonic/gin"
	api "nowis/internal/gateway/controller"
)

func InitApi() *gin.Engine {
	router := gin.Default()
	apiV1 := router.Group("/v1")

	apiController := api.NewApiController()
	nowisController := api.NewNowisController()

	// Setup health-check routes.
	apiV1.GET("/health", apiController.Health)

	// Setup Auth routes.
	nowisGroup := apiV1.Group("/nowis")
	SetupNowisRoutes(nowisGroup, nowisController)

	return router
}
