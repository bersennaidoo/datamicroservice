.PHONY: all build build-cli rpc templates lint

all:
	drone exec

protocgrpc:
	protoc --proto_path=. -Itransport/rpc/stats --go_out=plugins=grpc,paths=source_relative:. transport/rpc/stats/stats.proto

protoctwirp:
	protoc --proto_path=. -Itransport/rpc/stats --twirp_out=paths=source_relative:. transport/rpc/stats/stats.proto

build: export GOOS = linux
build: export GOARCH = amd64
build: export CGO_ENABLED = 0
build: $(shell ls -d cmd/* | grep -v "\-cli" | sed -e 's/cmd\//build./')
	@echo OK.

build.%: SERVICE=$*
build.%:
	go build -o build/$(SERVICE)-$(GOOS)-$(GOARCH) ./cmd/$(SERVICE)/*.go


# build-cli
build-cli: export GOOS = linux
build-cli: export GOARCH = amd64
build-cli: export CGO_ENABLED = 0
build-cli: $(shell ls -d cmd/*-cli | sed -e 's/cmd\//build-cli./')
	@echo OK.

build-cli.%: SERVICE=$*
build-cli.%:
	go build -o build/$(SERVICE)-$(GOOS)-$(GOARCH) ./cmd/$(SERVICE)/*.go


# rpc generators

rpc: $(shell ls -d transport/rpc/* | sed -e 's/\//./' | sed -e 's/\//./')
	@echo OK.

transport.rpc.stats:
	protoc --proto_path=. -Itransport/rpc/stats --go_out=paths=source_relative:. transport/rpc/stats/stats.proto
	protoc --proto_path=. -Itransport/rpc/stats --twirp_out=paths=source_relative:. transport/rpc/stats/stats.proto

transport.rpc.%: SERVICE=$*

transport.rpc.%:
	@echo '> protoc gen for $(SERVICE)'
	@protoc --proto_path=. -Irpc/$(SERVICE) --go_out=plugins=grpc,paths=source_relative:. rpc/$(SERVICE)/$(SERVICE).proto
	@protoc --proto_path=. -Irpc/$(SERVICE) --twirp_out=paths=source_relative:. rpc/$(SERVICE)/$(SERVICE).proto

# template generate

templates: export MODULE=$(shell grep ^module go.mod | sed -e 's/module //g')
templates: $(shell ls -d transport/rpc/* | sed -e 's/rpc\//templates./g')
	@echo OK.

transport/templates.%: export SERVICE=$*
transport/templates.%: export SERVICE_CAMEL=$(shell echo $(SERVICE) | sed -r 's/(^|_)([a-z])/\U\2/g')
transport/templates.%:
	mkdir -p cmd/$(SERVICE) transport/rpc/$(SERVICE)/client transport/rpc/$(SERVICE)/server
	@envsubst < foundation/templates/cmd_main.go.tpl > cmd/$(SERVICE)/main.go
	@envsubst < foundation/templates/client_client.go.tpl > transport/rpc/$(SERVICE)/client/client.go
	@echo "~ transport/rpc/$(SERVICE)/client/client.go"
	@./foundation/templates/server_server.go.sh

# database migrations

migrate: $(shell ls -d infrastructure/repositories/mysqldb/schema/*/migrations.sql | xargs -n1 dirname | sed -e 's/infrastructure.repositories.mysqldb.schema./migrate./')
	@echo OK.

migrate.%: export SERVICE = $*
migrate.%: export MYSQL_ROOT_PASSWORD = bersen
migrate.%: DSN = "root:bersen@tcp(localhost:3306)/stats"
migrate.%:
	mysql -h localhost -u root -p$(MYSQL_ROOT_PASSWORD) -e "CREATE DATABASE IF NOT EXISTS $(SERVICE);"
	mysql -h localhost -u root -p$(MYSQL_ROOT_PASSWORD) -e "CREATE DATABASE IF NOT EXISTS migrations;"
	./build/mysqldb-migrate-cli-linux-amd64 -service $(SERVICE) -db-dsn "root:$(MYSQL_ROOT_PASSWORD)@tcp(localhost:3306)/$(SERVICE)" -real=true
	./build/mysqldb-migrate-cli-linux-amd64 -service $(SERVICE) -db-dsn "root:$(MYSQL_ROOT_PASSWORD)@tcp(localhost:3306)/$(SERVICE)" -real=true
	@mkdir -p server/$(SERVICE)
	@find server/$(SERVICE) -name types_gen.go -delete
	@rm -rf docs/schema/$(SERVICE)
	./build/mysqldb-schema-cli-linux-amd64 -service $(SERVICE) -schema stats -db-dsn $(DSN) -format go -output server/$(SERVICE)
	./build/mysqldb-schema-cli-linux-amd64 -service $(SERVICE) -schema stats -db-dsn $(DSN) -format markdown -output docs/schema/$(SERVICE)
	./build/mysqldb-schema-cli-linux-amd64 -schema migrations -db-dsn $(DSN) -drop=true

# lint code

lint:
	golangci-lint run --enable-all -D gomnd,gochecknoglobals,godox,gofmt,wsl,lll,gocognit,funlen ./...

