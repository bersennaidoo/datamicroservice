package main

import (
  "log"
  "context"
  "strings"

  "net/http"

  _ "github.com/go-sql-driver/mysql"

  "${MODULE}/transport/rpc/${SERVICE}"

  server "${MODULE}/transport/rpc/${SERVICE}/server"
)

func wrapWithIP(h http.Handler) http.Handler {
  return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            ip := func() string {
             headers := []string{
             http.CanonicalHeaderKey("X-Forwarded-For"),
             http.CanonicalHeaderKey("X-Real-IP"),
             }
             for _, header := range headers {
                 if addr := r.Header.Get(header); addr != "" {
                     return strings.SplitN(addr, ", ", 2)[0]
                 }
             }
             return strings.SplitN(r.RemoteAddr, ":", 2)[0];
         }()
         ctx := r.Context()
         ctx = context.WithValue(ctx, "ip.address", ip)
         h.ServeHTTP(w, r.WithContext(ctx))
     })
}

func main() {
  ctx := context.TODO()

  srv, err := server.New(ctx)
  if err != nil {
    log.Fatalf("Error in service.New(): %+v", err)
  }

  twirpHandler := ${SERVICE}.New${SERVICE_CAMEL}ServiceServer(srv, nil)

  http.ListenAndServe(":3000", twirpHandler)
  http.ListenAndServe(":3000", wrapWithIP(twirpHandler))
}

