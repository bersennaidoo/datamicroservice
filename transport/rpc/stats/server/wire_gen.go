// Code generated by Wire. DO NOT EDIT.

//go:generate go run github.com/google/wire/cmd/wire
//go:build !wireinject
// +build !wireinject

package server

import (
	"context"
	"github.com/bersennaidoo/microdataservice/foundation/inject"
	"github.com/bersennaidoo/microdataservice/infrastructure/repositories/mysqldb"
)

// Injectors from wire.go:

func New(ctx context.Context) (*Server, error) {
	db, err := mysqldb.Connect(ctx)
	if err != nil {
		return nil, err
	}
	sonyflake := inject.Sonyflake()
	server := &Server{
		db:        db,
		sonyflake: sonyflake,
	}
	return server, nil
}
