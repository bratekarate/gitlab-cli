#!/bin/sh

error() {
  echo "Error: $1" >&2
  exit 1
}

eval_picker() {
  eval "$GLAB_PICKER"
}

shell_picker() {
  LIST=$(cat)
  printf '%b\n' "$LIST" >&2

  while ! echo "$N" | grep -q '^[0-9]\+$' ||
    [ "$N" -ge "$(echo "$LIST" | wc -l)" ]; do
    printf '\n%s: ' "$1" >&2
    read -r N
  done </dev/tty

  printf '%b\n' "$LIST" | sed -n "/^$N/p"
}

MRID_ONLY=0
PROP=name
while getopts ':abc:defghijkl:mMnopqrstuvwxyz' O; do
  case "$O" in
  p)
    PROP=path_with_namespace
    ;;
  m)
    PROP=title
    ;;
  M)
    PROP=title
    MRID_ONLY=1
    ;;
  c)
    PROP=$OPTARG
    ;;
  l)
    LABEL=$OPTARG
    ;;
  *)
    error "Unknown parameter -$O"
    ;;
  esac
done

if command -v "$(echo "$GLAB_PICKER" | cut -d' ' -f1)" >/dev/null; then
  set -- eval_picker
elif command -v rofi >/dev/null; then
  set -- rofi -dmenu -i -no-custom -p
else
  set -- shell_picker
fi

export JSON_FILE=/tmp/glpick_$$.json
PICKED=$(tee "$JSON_FILE" | jq -e 'type == "array"' >/dev/null ||
  {
    error 'not an array response'
  } &&
  L=$(jq 'length' "$JSON_FILE") &&
  [ "$L" -gt 0 ] ||
  error 'No object was found.' &&
  if [ "$L" -eq 1 ]; then
    jq -r '.[0]' "$JSON_FILE"
  else
    CHOICE=$(jq -r ".[] | \"\(.n)\t\(.id)\t\(.$PROP)\"" "$JSON_FILE" |
      "$@" "${LABEL:-Pick}") || exit &&
      printf '%s' "$CHOICE" | cut -d '	' -f1 |
      xargs -I {} sh -c 'jq ".[] | select(.n == {})" "$JSON_FILE"'
  fi) &&
  if [ "$MRID_ONLY" -eq 1 ]; then
    printf '%s' "$PICKED" | glmergecut
  else
    printf '%s' "$PICKED" | jq
  fi
