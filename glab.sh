#!/bin/sh

[ "$#" -lt 1 ] &&
  {
    echo "Error: missing arguments" >&2
    exit 1
  }

URI=$1
shift

curl -H "$TOKEN" "$BASEURL/api/v4/$URI" | 
  jq "$@" --raw-output \
  'if type == "array" then to_entries | [ .[] | {n: .key} + .value ] else . end'
