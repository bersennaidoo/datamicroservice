.PHONY: all build rpc

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
	go build -o ./build ./cmd/...

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

templates: export MODULE=$(shell grep ^module go.mod | sed -e 's/module //g')
templates: $(shell ls -d transport/rpc/* | sed -e 's/rpc\//templates./g')
	@echo OK.

transport/templates.%: export SERVICE=$*
transport/templates.%: export SERVICE_CAMEL=$(shell echo $(SERVICE) | sed -r 's/(^|_)([a-z])/\U\2/g')
transport/templates.%:
	mkdir -p cmd/$(SERVICE)
	@envsubst < templates/cmd_main.go.tpl > cmd/$(SERVICE)/main.go
