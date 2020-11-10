#!/bin/sh

# TODO: this is a draft for reference (although usable). Turn it into a proper,
# reusable script.

[ "$#" -eq 5 ] ||
	{
		echo "Error: Please provide project id, title, source branch, target branch and assignee id, in that order." >&2
		exit 1
	}

DATA=$(
	cat <<-EOM | tr -d '\t'
		{\
		  "id": "$1",\
		  "title": "$2",\
		  "source_branch": "$3",\
		  "target_branch":"$4",\
		  "assignee_id": $5,\
		  "remove_source_branch": true\
		}
	EOM
)

glab projects/"$1"/merge_requests \
 -X POST -H 'Content-Type: application/json' \
 --data "$DATA"
