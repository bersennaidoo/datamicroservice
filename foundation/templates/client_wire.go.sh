#!/bin/bash
cd $(dirname $(dirname  $(readlink -f $0)))

## list all services
schemas=$(ls -d /home/bersen/go_projects/microdataservice/transport/rpc/* | xargs -n1 basename)
echo $schemas

function render_wire {
	echo "package wireclient"
	echo
	echo "import ("
	echo -e "\t\"github.com/google/wire\""
	echo
	for schema in $schemas; do
		echo -e "\t\"${MODULE}/transport/rpc/${schema}\""
	done
	echo ")"
	echo
	echo "// Inject produces a wire.ProviderSet with our RPC clients"
	echo "var Inject = wire.NewSet("
	for schema in $schemas; do
		echo -e "\t${schema}.NewStatsServiceJSONClient,"
	done
	echo ")"
}

render_wire > /home/bersen/go_projects/microdataservice/transport/rpc/stats/wireclient/wire.go
echo "~ /home/bersen/go_projects/microdataservice/transport/rpc/stats/wireclient/wire.go"

