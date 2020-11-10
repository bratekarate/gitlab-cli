#!/bin/sh

JQDIFF='.changes | .[] | "diff --git a/glsimp.sh b/glsimp2.sh\n--- '"\
"'\(.old_path)\n+++ \(.new_path)\n\(.diff)"'

JSON=$(glab projects/"$1"/merge_requests/"$2"/changes) &&
  echo "$JSON" | jq -e 'length > 0' > /dev/null &&
	echo "$JSON" | jq --compact-output --raw-output "$JQDIFF"
