package server

import (
  "context"
  
  "github.com/jmoiron/sqlx"
  "github.com/sony/sonyflake"

  "${MODULE}/transport/rpc/${SERVICE}"
)

type Server struct {
  db *sqlx.DB
  sonyflake *sonyflake.Sonyflake
}

var _ ${SERVICE}.${SERVICE_CAMEL}Service = &Server{}
