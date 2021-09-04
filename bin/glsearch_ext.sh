#!/bin/sh

handle_key() {
  HK_HEAD=$(cat)
  if GRP=$(printf '%s\n' "$HK_HEAD" | grep "rel=\"$1\""); then
    printf '%s\n' "$GRP" | cut -d ';' -f1
  else
    printf '%s\n' "$HK_HEAD" | grep "rel=\"$2\"" | cut -d ';' -f1
  fi
}

CODE=
RAW=$(glsearch_pages "$@")
while [ -z "$CODE" ] || { [ "$CODE" -ne 0 ] && [ "$CODE" -ne 1 ] && [ "$CODE" -ne 2 ]; }; do
  HEAD=$(
    printf '%s\n' "$RAW" |
      sed '$ d' |
      awk -F ': ' '/Link:/{print $2}' |
      tr ',' '\n' |
      tr -d '<' |
      tr -d '>' |
      tr -d ' '
  )
  RES=$(
    printf '%s\n' "$RAW" |
      tail -n 1 |
      jq -r 'if type == "array" then to_entries | [ .[] | {n: .key} + .value ] else . end'
  )

  # TODO: How to customize glpick command?
  printf '%s\n' "$RES" | glpick
  CODE=$?

  case "$CODE" in
  0|1|2) exit "$CODE" ;;
  10) URL=$(printf '%s\n' "$HEAD" | handle_key next last) ;;
  11) URL=$(printf '%s\n' "$HEAD" | handle_key prev first) ;;
  esac

  RAW=$(glab "$(printf '%s\n' "$URL" | sed 's|.*/v4\(/.*\)|\1|g')")
done
