#!/bin/sh

case "$1" in
projects | groups)
  TYPE=$1
  shift
  SEARCH=$1
  shift
	glab "$TYPE?simple=true&search=$SEARCH"
	;;
*)
	echo "Error: '$1' is not a valid search type" >&2
	exit 1
	;;
esac
