package service

import (
	nowispb "nowis/protobuf/generated/nowis"
)

type NowisService struct {
	nowispb.NowisServiceServer
}

func NewNowisService() NowisService {
	return NowisService{}
}
