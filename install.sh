#!/bin/sh

[ -z "$1" ] && {
    echo "Error: target directory must be specified" >&2
    exit 1
}

find "$PWD"/bin -type f -name "*.??" -exec test -x {} \; -print0 |
    xargs -0 -I {} sh -c 'ln -sf "$1" "${2%/}/$(basename "${1%.*}")"' _ {} "$1"
