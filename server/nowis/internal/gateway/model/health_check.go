package model

import (
	nowispb "nowis/protobuf/generated/nowis"
)

type HealthCheckResponse struct {
	AppId         string `json:"appId"`
	AppVersionRef string `json:"appVersionRef"`
}

func FromPBHealthCheckResponse(pbResponse *nowispb.HealthCheckResponse) *HealthCheckResponse {
	return &HealthCheckResponse{
		AppId:         pbResponse.AppId,
		AppVersionRef: pbResponse.AppVersionRef,
	}
}

func (h *HealthCheckResponse) ToGinMap() map[string]interface{} {
	return map[string]interface{}{
		"appId":         h.AppId,
		"appVersionRef": h.AppVersionRef,
	}
}
