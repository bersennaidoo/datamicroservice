package main

import (
	"flag"
	"log"

	"github.com/SentimensRG/sigctx"
	"github.com/bersennaidoo/microdataservice/infrastructure/repositories/mysqldb"
	_ "github.com/go-sql-driver/mysql"
)

func main() {
	var config struct {
		db      mysqldb.ConnectionOptions
		real    bool
		service string
	}
	flag.StringVar(&config.db.Credentials.Driver, "db-driver", "mysql", "Database driver")
	flag.StringVar(&config.db.Credentials.DSN, "db-dsn", "", "DSN for database connection")
	flag.StringVar(&config.service, "service", "", "Service name for migrations")
	flag.BoolVar(&config.real, "real", false, "false = print migrations, true = run migrations")
	flag.Parse()

	if config.service == "" {
		log.Printf("Available migration services: %+v", mysqldb.List())
		log.Fatal()
	}

	ctx := sigctx.New()

	switch config.real {
	case true:
		handle, err := mysqldb.ConnectWithRetry(ctx, config.db)
		if err != nil {
			log.Fatalf("Error connecting to database: %+v", err)
		}
		if err := mysqldb.Run(config.service, handle); err != nil {
			log.Fatalf("An error occurred: %+v", err)
		}
	default:
		if err := mysqldb.Print(config.service); err != nil {
			log.Fatalf("An error occurred: %+v", err)
		}
	}
}
