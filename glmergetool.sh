#!/bin/sh

# TODO: remove workaround as soon as jq is released
CHOICE=$(glsearch projects "$1" | glpick -p) || exit
PRID=$(echo "$CHOICE" | jq -e '.id')

[ -n "$2" ] &&
  if [ "$2" = 'me' ]; then
    ASSIGNEE='scope=assigned-to-me'
  else
    if echo "$2" | grep -iq '^[0-9]\+$'; then
      ASID=$2
    else
      CHOICE=$(glsearch users "$2" | glpick) || exit
      ASID=$(echo "$CHOICE" | jq '.id')
    fi
    ASSIGNEE="assignee_id=$ASID"
  fi

URL="projects/$PRID/merge_requests?state=opened"

[ -n "$ASSIGNEE" ] &&
  URL="$URL&$ASSIGNEE"

CHOICE=$(glab "$URL" | glpick m) || exit
IID=$(echo "$CHOICE" | jq '.iid')

glmergerev "$PRID" "$IID"
