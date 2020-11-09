#!/bin/sh

[ "$#" -lt 2 ] &&
  {
    echo 'Error: missing argument' >&2
    exit 1
  }

case "$1" in
projects | groups)
  TYPE=$1
  shift
  SEARCH=$1
  shift
	glab "$TYPE?simple=true&search=$SEARCH&per_page=100" "$@"
	;;
*)
	echo "Error: '$1' is not a valid search type" >&2
	exit 1
	;;
esac
