package routers

import (
	"github.com/gin-gonic/gin"
	api "nowis/internal/gateway/controller"
)

func SetupNowisRoutes(r *gin.RouterGroup, controller api.NowisController) {
	r.GET("/:id", controller.GetPostById)
}
