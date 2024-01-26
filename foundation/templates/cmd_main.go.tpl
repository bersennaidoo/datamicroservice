package main

import (
  "log"
  "context"

  "net/http"

  _ "github.com/go-sql-driver/mysql"

  "${MODULE}/transport/rpc/${SERVICE}"

  server "${MODULE}/transport/rpc/${SERVICE}/server"
)

func main() {
  ctx := context.TODO()

  srv, err := server.New(ctx)
  if err != nil {
    log.Fatalf("Error in service.New(): %+v", err)
  }

  twirpHandler := ${SERVICE}.New${SERVICE_CAMEL}ServiceServer(srv, nil)

  http.ListenAndServe(":3000", twirpHandler)
}

