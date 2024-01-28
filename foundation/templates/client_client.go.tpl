package client

import (
  "net/http"

  "${MODULE}/transport/rpc/${SERVICE}"
)

 func New() ${SERVICE}.${SERVICE_CAMEL}Service {
   return NewCustom("http://${SERVICE}.service:3000", &http.Client{})
}

 func NewCustom(addr string, client ${SERVICE}.HTTPClient) ${SERVICE}.${SERVICE_CAMEL}Service {
  return ${SERVICE}.New${SERVICE_CAMEL}ServiceJSONClient(addr, client)
}



  
