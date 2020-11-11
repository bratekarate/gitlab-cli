#!/bin/sh

error() {
    echo "Error: $1" >&2
    exit 1
}

[ -z "$1" ] &&
    error 'Type (msys or cygwin) must be specified.' 

LINKOPT=winsymlinks:nativestrict

case "$1" in
    msys)
        export MSYS=$LINKOPT
        ;;
    cygwin)
        export CYGWIN=$LINKOPT
        ;;
    *)
        error 'Illegal type specified. must be msys or cygwin'
esac

./install.sh "$2"

DLURL=$(curl -fsS https://api.github.com/repos/stedolan/jq/releases/latest | grep 'browser.*win64' | cut -d '"' -f4) || exit

curl -Lf "$DLURL" > /usr/bin/jq_raw.exe

printf '#!/bin/sh\n\njq_raw "$@" | tr -d '\''\\r'\' > /usr/bin/jq


