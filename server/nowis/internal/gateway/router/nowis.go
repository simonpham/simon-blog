package routers

import (
	api "nowis/internal/gateway/controller"

	"github.com/gin-gonic/gin"
)

func SetupNowisRoutes(r *gin.RouterGroup, controller api.NowisController) {
	r.GET("/health", controller.HealthCheck)
	r.GET("/posts", controller.GetPosts)
	r.GET("/:id", controller.GetPostById)
	r.GET("/slug/:slug", controller.GetPostBySlug)
	r.GET("/sidebar-posts-by-tags", controller.GetSidebarPostsByTags)
	r.GET("/comments", controller.GetComments)
}
