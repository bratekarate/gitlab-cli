#!/bin/sh

error() {
	echo "Error: $1" >&2
	exit 1
}

[ "$#" -lt 1 ] &&
	error 'missing arguments.'

TOKEN=${TOKEN:-$(eval "$TOKEN_CMD")}
URI=$1
shift

# shellcheck disable=SC2016
[ -z "$TOKEN" ] || [ -z "$BASEURL" ] &&
	error 'env variables $BASEURL and either $TOKEN or $TOKEN_CMD must be set.'

curl "$@" -H "PRIVATE-TOKEN: $TOKEN" "$BASEURL/api/v4/$URI" |
	jq --raw-output \
		'if type == "array" then to_entries | [ .[] | {n: .key} + .value ] else . end'
