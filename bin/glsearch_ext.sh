#!/bin/sh

CODE=
RAW=$(glsearch_pages "$@")
while [ -z "$CODE" ] || { [ "$CODE" -ne 0 ] && [ "$CODE" -ne 1 ] && [ "$CODE" -ne 2 ]; }; do
  HEAD=$(printf '%s\n' "$RAW" | sed '$ d' | awk -F ': ' '/Link:/{print $2}' | tr ',' '\n' | tr -d '<' | tr -d '>' | tr -d ' ')
  RES=$(printf '%s\n' "$RAW" | tail -n 1 | jq -r 'if type == "array" then to_entries | [ .[] | {n: .key} + .value ] else . end')
  printf '%s\n' "$RES" | glpick
  CODE=$?

  [ "$CODE" -eq 10 ] &&
    if GRP=$(printf '%s\n' "$HEAD" | grep 'rel="next"'); then
      URL=$(printf '%s\n' "$GRP" | cut -d ';' -f1)
    else
      URL=$(printf '%s\n' "$HEAD" | grep 'rel="last"' | cut -d ';' -f1)
    fi

  [ "$CODE" -eq 11 ] &&
    if GRP=$(printf '%s\n' "$HEAD" | grep 'rel="prev"'); then
      URL=$(printf '%s\n' "$GRP" | cut -d ';' -f1)
    else
      URL=$(printf '%s\n' "$HEAD" | grep 'rel="first"' | cut -d ';' -f1)
    fi

  URL=$(printf '%s\n' "$URL" | sed 's|.*/v4\(/.*\)|\1|g')
  RAW=$(glab "$URL")
done
