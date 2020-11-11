#!/bin/sh

[ "$#" -lt 2 ] &&
  {
    echo "Error: missing arguments" >&2
    exit 1
  }

glmergediff "$1" "$2" > /tmp/glmerge.diff &&
  vim /tmp/glmerge.diff < /dev/tty &&
  P='y\(es\)\?' &&
  while ! echo "$A" | grep -iq "^\($P\|no\?\)$"; do
    printf 'Accept merge request? [y/n] ' &&
    read -r A
  done < /dev/tty &&
  echo "$A" |  grep -iq "^$P$" &&
  glmergeacc 449 1
