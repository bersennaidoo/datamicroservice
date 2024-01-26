package server

import (
	"context"

	"github.com/bersennaidoo/microdataservice/transport/rpc/stats"
)

type Server struct {
}

func New(ctx context.Context) (*Server, error) {
	return &Server{}, nil
}

var _ stats.StatsService = &Server{}

func (svc *Server) Push(_ context.Context, _ *stats.PushRequest) (*stats.PushResponse, error) {
	panic("not implemented") // TODO: Implement
}
