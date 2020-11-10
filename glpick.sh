#!/bin/sh

# TODO: fix trap (sometimes it just fires in the middle of the script)
#trap 'cleanup' EXIT
#trap 'exit 1' INT HUP QUIT TERM

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
		[ "$N" -ge "$(echo "$LIST" | wc -l)" ]; do
		printf '\n%s: ' "$1" >&2
		read -r N
	done </dev/tty

	printf '%b\n' "$LIST" | sed -n "/^\[$N\]/{s/\[$N\] //g;p}"
}

TYPE=$1
case "$TYPE" in
p | projects)
	PROP=path_with_namespace
	;;
m | merge_requests)
	PROP=title
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

cat - >/tmp/glab.json &&
	jq --raw-output type /tmp/glab.json | grep -iq '^array$' ||
	{
		error 'Error: not an array response'
	} &&
	L=$(jq 'length' /tmp/glab.json) &&
	[ "$L" -gt 0 ] ||
	error 'No object was found.' &&
	if [ "$L" -eq 1 ]; then
		jq --raw-output '.[0]' /tmp/glab.json
	else
		CHOICE=$(jq --raw-output ".[] | \"\(.id)	\(.$PROP)\"" /tmp/glab.json |
			"$@" "${LABEL:-Pick}") || exit &&
			echo "$CHOICE" | cut -d '	' -f1 |
			xargs -I {} jq '.[] | select(.id == {})' /tmp/glab.json
	fi
