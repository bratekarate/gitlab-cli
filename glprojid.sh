#!/bin/sh

trap 'rm /tmp/glab.json 2>/dev/null' EXIT
trap 'exit' INT HUP

[ "$#" -lt 1 ] &&
  {
    echo 'Error: missing argument' >&2
    exit 1
  }

PROJECT=$1
shift

[ "$#" -eq 0 ] &&
  set -- rofi -dmenu -p 'Project' -no-custom

# shellcheck disable=SC2015
glsearch projects "$PROJECT" -sSf >/tmp/glab.json &&
	L=$(jq -e 'length' /tmp/glab.json) &&
	[ "$L" -gt 0 ] && {
		[ "$L" -eq 1 ] &&
		{ jq --raw-output '.[0]' /tmp/glab.json || exit; } ||
		jq --raw-output '.[] | "\(.id)	\(.path_with_namespace)"' /tmp/glab.json |
		"$@" |
			cut -d '	' -f1 |
			xargs -I {} jq '.[] | select(.id == {})' /tmp/glab.json
} | glsimp | jq_append
