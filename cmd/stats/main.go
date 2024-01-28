package main

import (
	"context"
	"flag"
	"log"
	"strings"

	"net/http"

	"github.com/SentimensRG/sigctx"
	_ "github.com/go-sql-driver/mysql"

	"github.com/bersennaidoo/microdataservice/infrastructure/repositories/mysqldb"
	"github.com/bersennaidoo/microdataservice/transport/rpc/stats"

	server "github.com/bersennaidoo/microdataservice/transport/rpc/stats/server"
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
			return strings.SplitN(r.RemoteAddr, ":", 2)[0]
		}()
		ctx := r.Context()
		ctx = context.WithValue(ctx, "ip.address", ip)
		h.ServeHTTP(w, r.WithContext(ctx))
	})
}

func main() {
	var config struct {
		migrate   bool
		migrateDB mysqldb.ConnectionOptions
	}
	flag.StringVar(&config.migrateDB.Credentials.Driver, "migrate-db-driver", "mysql", "Migrations: Database driver")
	flag.StringVar(&config.migrateDB.Credentials.DSN, "migrate-db-dsn", "root:bersen@tcp(localhost:3306)/stats", "Migrations: DSN for database connection")
	flag.BoolVar(&config.migrate, "migrate", false, "Run migrations?")
	flag.Parse()

	ctx := sigctx.New()

	if config.migrate {
		handle, err := mysqldb.ConnectWithRetry(ctx, config.migrateDB)
		if err != nil {
			log.Fatalf("Error connecting to database: %+v", err)
		}
		if err := mysqldb.Run("stats", handle); err != nil {
			log.Fatalf("An error occurred: %+v", err)
		}
	}

	srv, err := server.New(ctx)
	if err != nil {
		log.Fatalf("Error in service.New(): %+v", err)
	}

	twirpHandler := stats.NewStatsServiceServer(srv, NewServerHooks())

	log.Println("Starting service on port :3000")
	go func() {
		err := http.ListenAndServe(":3000", wrapWithIP(twirpHandler))
		if err != http.ErrServerClosed {
			log.Println("Server error:", err)
		}
	}()
	<-ctx.Done()

	//srv.Shutdown()
	log.Println("Done.")
}
