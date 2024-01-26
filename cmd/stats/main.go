package main

import (
  "log"
  "context"

  "net/http"

  _ "github.com/go-sql-driver/mysql"

  "github.com/bersennaidoo/microdataservice/transport/rpc/stats"

  server "github.com/bersennaidoo/microdataservice/transport/rpc/stats/server"
)

func main() {
  ctx := context.TODO()

  srv, err := server.New(ctx)
  if err != nil {
    log.Fatalf("Error in service.New(): %+v", err)
  }

  twirpHandler := stats.NewStatsServiceServer(srv, nil)

  http.ListenAndServe(":3000", twirpHandler)
}

