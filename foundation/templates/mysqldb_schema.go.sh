#!/bin/bash

## encode file contents in base64
function base64_encode {
	cat $1 | base64 -w 0
}

## generate a service FS
function render_service_schema {
	local schema=$(basename $1)
	echo "package mysqldb"
	echo
	echo "var $schema FS = FS{"
	local files=$(find $1 -name '*.sql' | sort)
	for file in $files; do
		echo "\"$(basename $file)\": \"$(base64_encode $file)\","
	done
	echo "}"
}

## list all service FS into `migrations` global
function render_schema {
	echo "package mysqldb"
	echo
	echo "var migrations map[string]FS = map[string]FS{"
	for schema in $schemas; do
		local package=$(basename $schema)
		echo "\"${package}\": ${package},"
	done
	echo "}"
}

schemas=$(ls /home/bersen/go_projects/microdataservice/infrastructure/repositories/mysqldb/schema/*/migrations.sql | xargs -n1 dirname | sort)

for schema in $schemas; do
    #schema_relative=${schema/mysqldb\//}
    output="infrastructure/repositories/mysqldb/schema.go"

    render_service_schema $schema > $output
done

render_schema > infrastructure/repositories/mysqldb/schema.go

