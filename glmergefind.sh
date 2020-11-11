#!/bin/sh

while getopts ":abcdefghijklmnopqrstuvwxyz" O; do
  case "$O" in
    i)
      IDS_ONLY=1
      ;;
    *)
      echo "Error: unknown option -$O." >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# TODO: remove workaround as soon as jq is released
PROJECT=$(glsearch projects "$1" | glpick -p) || exit 1
PRID=$(echo "$PROJECT" | jq -e '.id')

[ -n "$2" ] &&
  if [ "$2" = 'me' ]; then
    ASSIGNEE='scope=assigned-to-me'
  else
    if echo "$2" | grep -iq '^[0-9]\+$'; then
      ASID=$2
    else
      CHOICE=$(glsearch users "$2" | glpick) || exit 1
      ASID=$(echo "$CHOICE" | jq -e '.id')
    fi
    ASSIGNEE="assignee_id=$ASID"
  fi

URL="projects/$PRID/merge_requests?state=opened"

[ -n "$ASSIGNEE" ] &&
  URL="$URL&$ASSIGNEE"

MR=$(glab "$URL" | glpick m) || exit 1

set -- jq -e

[ "$IDS_ONLY" -eq 1 ] &&
  set -- "$@" --raw-output '"\(.project_id)\n\(.iid)"'

printf '%s\n' "$MR" | "$@"
