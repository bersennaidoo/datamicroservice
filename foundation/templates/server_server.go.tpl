package server

import (
  "context"
  
  "github.com/jmoiron/sqlx"

  "${MODULE}/transport/rpc/${SERVICE}"
)

type Server struct {
  db *sqlx.DB
}

var _ ${SERVICE}.${SERVICE_CAMEL}Service = &Server{}
