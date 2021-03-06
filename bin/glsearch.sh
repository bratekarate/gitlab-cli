#!/bin/sh

[ "$#" -lt 1 ] &&
  {
    echo 'Error: missing argument' >&2
    exit 1
  }

TYPE=$1
shift
[ -n "${1+x}" ] &&
  {
    SEARCH=$1
    shift
  }

[ -n "${1+x}" ] &&
  {
    PAGE=$1
    shift
  }

PAGE=${PAGE-1}

URL="$TYPE?simple=true&search_namespaces=true&per_page=100&page=$PAGE"

# TODO: consider a cleaner way to handle extra params
[ -n "$SEARCH" ] && URL="$URL&search=$(
  echo "$SEARCH" | cut -d '?' -f1 | tr ' ' '+'
)" && echo "$SEARCH" | grep -q '?' &&
  URL="$URL&$(
    echo "$SEARCH" | cut -d '?' -f2
  )"

glab "$URL" "$@"
