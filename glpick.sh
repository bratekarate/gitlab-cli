#!/bin/sh

trap 'cleanup' EXIT
trap 'exit 1' INT HUP QUIT TERM

cleanup() {
	rm /tmp/glab.json 2>/dev/null
  exit
}

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
    [ "$N" -ge "$(echo "$LIST" | wc -l)" ] ; do
		printf '\nProject index: ' >&2
		read -r N
	done </dev/tty

	printf '%b\n' "$LIST" | sed -n "/^\[$N\]/{s/\[$N\] //g;p}"
}

TYPE=$1

case "$TYPE" in
  p|projects)
    PROP=path_with_namespace
    ;;
  .*)
    PROP=${TYPE#.}
    ;;
  *)
    PROP=name
    ;;
esac

INPUT="${2:--}"

if command -v "$GLAB_PICKER" >/dev/null; then
    set -- eval_picker
  elif command -v rofi >/dev/null; then
    set -- rofi -dmenu -i -p 'Project' -no-custom
  else
    set -- shell_picker
  fi

cat "$INPUT" > /tmp/glab.json &&
  jq --raw-output type /tmp/glab.json | grep -iq '^array$' ||
  {
    error 'Error: not an array response'
  } &&
	L=$(jq 'length' /tmp/glab.json) &&
	[ "$L" -gt 0 ] ||
	error 'No project was found.' &&
	if [ "$L" -eq 1 ]; then
		jq --raw-output '.[0]' /tmp/glab.json
	else
		jq --raw-output ".[] | \"\(.id)	\(.$PROP)\"" /tmp/glab.json |
      "$@" |
      cut -d '	' -f1 |
      xargs -I {} jq '.[] | select(.id == {})' /tmp/glab.json
	fi
