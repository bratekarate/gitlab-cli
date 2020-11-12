#!/bin/sh

ACCEPT_MERGE=0
while getopts ":abcdefghijklmnopqrstuvwxyz" O; do
	case "$O" in
	m)
		ACCEPT_MERGE=1
		;;
	*)
		echo "Error: unknown option -$O." >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

[ "$#" -lt 2 ] &&
  {
    echo "Error: missing arguments" >&2
    exit 1
  }

PRPATH=$(glab projects/"$1" | jq --raw-output '.path' | sed 's|/|_|g')
TITLE=$(glab projects/"$1"/merge_requests/"$2"| jq --raw-output '.title' | sed 's/ /_/g')

FILENAME="/tmp/${PRPATH}-$TITLE"
glmergediff "$1" "$2" > "$FILENAME" &&
    {
      vim "$FILENAME" +'w' < /dev/tty
      rm "$FILENAME"
    } &&
  [ "$ACCEPT_MERGE" -eq 1 ] &&
  P='y\(es\)\?' &&
  while ! echo "$A" | grep -iq "^\($P\|no\?\)$"; do
    printf 'Accept merge request? [y/n] ' &&
    read -r A
  done < /dev/tty &&
  echo "$A" |  grep -iq "^$P$" &&
  glmergeacc "$1" "$2"
