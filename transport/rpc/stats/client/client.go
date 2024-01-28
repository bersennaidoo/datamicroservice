package client

import (
  "net/http"

  "github.com/bersennaidoo/microdataservice/transport/rpc/stats"
)

 func New() stats.StatsService {
   return NewCustom("http://stats.service:3000", &http.Client{})
}

 func NewCustom(addr string, client stats.HTTPClient) stats.StatsService {
  return stats.NewStatsServiceJSONClient(addr, client)
}



  
