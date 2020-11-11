#!/usr/bin/jq -f

(if type == "array" then .[] else . end) | "\(.project_id)\n\(.iid)"
