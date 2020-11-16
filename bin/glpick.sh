#!/bin/sh

error() {
  echo "$1" >&2
  exit 1
}

eval_picker() {
  eval "$GLAB_PICKER"
}

shell_picker() {
  LIST=$(awk '{print "["NR-1"] "$0}')
  printf '%b\n' "$LIST" >&2

  while ! echo "$N" | grep -q '^[0-9]\+$' ||
    [ "$N" -ge "$(echo "$LIST" | wc -l)" ]; do
    printf '\n%s: ' "$1" >&2
    read -r N
  done </dev/tty

  printf '%b\n' "$LIST" | sed -n "/^\[$N\]/{s/\[$N\] //g;p}"
}

TYPE=$1
MRID_ONLY=0
case "$TYPE" in
p | projects)
  PROP=path_with_namespace
  ;;
m | merge_requests)
  PROP=title
  ;;
M | merge_requests_ids)
  PROP=title
  MRID_ONLY=1
  ;;
.*)
  PROP=${TYPE#.}
  ;;
*)
  PROP=name
  ;;
esac

LABEL="$2"

if command -v "$(echo "$GLAB_PICKER" | cut -d' ' -f1)" >/dev/null; then
  set -- eval_picker
elif command -v rofi >/dev/null; then
  set -- rofi -dmenu -i -no-custom -p
else
  set -- shell_picker
fi

PICKED=$(JSON=$(cat) export JSON &&
  printf '%s' "$JSON" | jq -e 'type == "array"' >/dev/null ||
  {
    error 'Error: not an array response'
  } &&
  L=$(printf '%s' "$JSON" | jq 'length') &&
  [ "$L" -gt 0 ] ||
  error 'No object was found.' &&
  if [ "$L" -eq 1 ]; then
    printf '%s' "$JSON" | jq -r '.[0]'
  else
    CHOICE=$(printf '%s' "$JSON" | jq -r ".[] | \"\(.id)	\(.$PROP)\"" |
      "$@" "${LABEL:-Pick}") || exit &&
      printf '%s' "$CHOICE" | cut -d '	' -f1 |
      xargs -I {} sh -c 'printf "%s" "$JSON" | jq ".[] | select(.id == {})"'
  fi) &&
  if [ "$MRID_ONLY" -eq 1 ]; then
    printf '%s' "$PICKED" | glmergecut
  else
    printf '%s' "$PICKED" | jq
  fi
