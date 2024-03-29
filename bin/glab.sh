#!/bin/sh

trap 'cleanup' EXIT

error() {
  echo "Error: $1" >&2
  exit 1
}

cleanup() {
  rm /tmp/curlout_$$.json 2>/dev/null
}

[ "$#" -lt 1 ] &&
  error 'missing arguments.'

TOKEN=${TOKEN:-$(eval "$TOKEN_CMD")}
URI=$1
shift

# shellcheck disable=SC2016
[ -z "$TOKEN" ] || [ -z "$BASEURL" ] &&
  error 'env variables $BASEURL and either $TOKEN or $TOKEN_CMD must be set.'

# TODO: fifo does not work on MSYS/CYGWIN. curl `-o` issue?
# mkfifo /tmp/curlout_$$.json

CODE=$(curl -Ssi "$@" \
    -H "Private-Token: $TOKEN" \
    -H 'Content-Type: application/json' \
    -o /tmp/curlout_$$.json -w '%{http_code}' \
    "$BASEURL/api/v4/$URI")

echo "HTTP Code: $CODE" >&2

cat /tmp/curlout_$$.json

if echo "$CODE" | grep -q '^2[0-9]\{2\}'; then
  exit 0
else
  exit 1
fi
