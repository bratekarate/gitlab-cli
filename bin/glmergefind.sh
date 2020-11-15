#!/bin/sh

while getopts ":a:bcdefghijklmnop:qrstuvwxyz" O; do
  case "$O" in
  p)
    PROJECT="$OPTARG"
    ;;
  a)
    ASSIGNEE="$OPTARG"
    ;;
  *)
    echo "Error: unknown option -$O." >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

if [ -n "$PROJECT" ]; then
  # TODO: remove workaround as soon as jq is released
  PROJECT=$(glsearch projects "$PROJECT" | glpick p) || exit 1
  PRID=$(echo "$PROJECT" | jq -e '.id')
  URL="projects/$PRID/merge_requests?state=opened"
else
  URL="merge_requests?state=opened"
fi

[ -n "$ASSIGNEE" ] &&
  if [ "$ASSIGNEE" = 'me' ]; then
    ASSIG_PARAM='scope=assigned-to-me'
  else
    if echo "$ASSIGNEE" | grep -iq '^[0-9]\+$'; then
      ASID=$ASSIGNEE
    else
      CHOICE=$(glsearch users "$ASSIGNEE" | glpick) || exit 1
      ASID=$(echo "$CHOICE" | jq -e '.id')
    fi
    ASSIG_PARAM="assignee_id=$ASID"
  fi

[ -n "$ASSIG_PARAM" ] &&
  URL="$URL&$ASSIG_PARAM"

URL="$URL&per_page=100"

glab "$URL" || exit 1
