#!/bin/sh

[ "$#" -lt 2 ] &&
  {
    echo "Error: missing arguments." >&2
    exit 1
  }

JQDIFF='.changes | .[] | "diff --git a/\(.old_path) b/\(.new_path)\n--- '"\
"'\(.old_path)\n+++ \(.new_path)\n\(.diff)"'

JSON=$(glab projects/"$1"/merge_requests/"$2"/changes) &&
  printf '%s\n' "$JSON" | jq -e 'length > 0' >/dev/null &&
  printf '%s\n' "$JSON" | jq --compact-output --raw-output "$JQDIFF"
