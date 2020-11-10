#!/bin/sh

[ "$#" -lt 1 ] &&
	{
		echo 'Error: missing argument' >&2
		exit 1
	}

TYPE=$1
SEARCH=$2
shift

[ -n "${SEARCH+x}" ] &&
	{
		shift
	}

URL="$TYPE?simple=true&per_page=100"

[ -n "$SEARCH" ] &&
	URL="$URL&search=$SEARCH"

glab "$URL" "$@"
