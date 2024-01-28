//+build wireinject

package server

import (
  "context"

  "github.com/google/wire"

  "${MODULE}/foundation/inject"
)

func New(ctx context.Context) (*Server, error) {
  wire.Build(
    inject.Inject,
    wire.Struct(new(Server), "*"),
  )
  return nil, nil
}
