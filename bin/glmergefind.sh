#!/bin/sh

INCLUDE_CLOSED=0
while getopts ":a:bcdefghijklmnop:qrstuvwxyz" O; do
  case "$O" in
  p)
    PROJECT="$OPTARG"
    ;;
  a)
    ASSIGNEE="$OPTARG"
    ;;
  c)
    INCLUDE_CLOSED=1
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
  PROJECT=$(glsearch projects "$PROJECT" | glpick -p) || exit 1
  PRID=$(echo "$PROJECT" | jq -e '.id')
  URL="projects/$PRID/merge_requests"
else
  URL="merge_requests"
fi

[ "$INCLUDE_CLOSED" -eq 0 ] && STATE_PARAM='state=opened'

ASSIGNED_ME='scope=assigned-to-me'
[ -n "$ASSIGNEE" ] || [ -z "$PROJECT" ] &&
  if [ -z "$ASSIGNEE" ] || [ "$ASSIGNEE" = 'me' ]; then
    ASSIG_PARAM=$ASSIGNED_ME
  else
    if echo "$ASSIGNEE" | grep -iq '^[0-9]\+$'; then
      # ASIGNEE argument is a natural number, use as ID
      ASID=$ASSIGNEE
    else
      # search for users with keyword ASSIGNEE
      CHOICE=$(glsearch users "$ASSIGNEE" | glpick) || exit 1
      ASID=$(echo "$CHOICE" | jq -e '.id')
    fi
    ASSIG_PARAM="assignee_id=$ASID"
  fi

PARAMS="$(for i in $STATE_PARAM $ASSIG_PARAM per_page=100; do printf '%s\n' "$i"; done)"

[ -n "$PARAMS" ] && URL="$URL?$(printf '%s' "$PARAMS" | paste -sd '&')"
# echo $URL

glbody "$URL" || exit 1
