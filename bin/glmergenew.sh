#!/bin/sh

# TODO: this is a draft for reference (although usable). Turn it into a proper,
# reusable script.

[ "$#" -lt 5 ] || [ "$#" -gt 6 ] &&
	{
		echo "Error: Please provide project id, title, source branch, target branch and assignee id, in that order." >&2
		exit 1
	}

TID=${6:-$1}
DATA=$(jq -n --arg id "$1" --arg ti "$2" --arg s "$3" \
  --arg ta "$4" --arg a "$5" --arg tid "$TID" \
  '{id:$id,title:$ti,source_branch:$s,target_branch:$ta,assignee_id:$a,target_project_id:$tid}')

glab projects/"$1"/merge_requests \
 -X POST -H 'Content-Type: application/json' \
 --data "$DATA"
