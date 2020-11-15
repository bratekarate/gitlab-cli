#!/bin/sh

trap 'cleanup' EXIT

error() {
	echo "Error: $1" >&2
	exit 1
}

cleanup() {
  rm /tmp/curlout.json 2>/dev/null
}

[ "$#" -lt 1 ] &&
	error 'missing arguments.'

TOKEN=${TOKEN:-$(eval "$TOKEN_CMD")}
URI=$1
shift

# shellcheck disable=SC2016
[ -z "$TOKEN" ] || [ -z "$BASEURL" ] &&
	error 'env variables $BASEURL and either $TOKEN or $TOKEN_CMD must be set.'

CODE=$(curl -s "$@" -H "PRIVATE-TOKEN: $TOKEN" "$BASEURL/api/v4/$URI" -o /tmp/curlout.json -w "%{http_code}")

jq --raw-output \
  'if type == "array" then to_entries | [ .[] | {n: .key} + .value ] else . end' /tmp/curlout.json

if echo "$CODE" | grep -q '^2[0-9]\{2\}'; then
  exit 0
else
  exit 1
fi
