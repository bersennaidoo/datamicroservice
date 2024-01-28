#!/bin/bash

payload='{
  "property": "news",
  "section": 2,
  "id": 2
}'

curl -s -X POST -H 'Content-Type: application/json' \
    -H "X-Real-IP: 9.9.9.9" \
    http://localhost:3000/twirp/stats.StatsService/Push \
    -d "$payload" | jq .


