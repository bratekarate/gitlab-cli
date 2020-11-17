#!/bin/sh

ACCEPT_MERGE=0
while getopts ":a:bcdefghijklmnop:qrstuvwxyz" O; do
  case "$O" in
  m)
    ACCEPT_MERGE=1
    ;;
  *) continue ;;
  esac
done

ARGS=$(for i in "$@"; do
  printf '%s' "$ARGS$i/"
done | sed 's|/$||g')

OLDIFS=$IFS
IFS='/'
set --
for i in $ARGS; do
  case "$i" in
  -m) ;;

  *)
    set -- "$@" "$i"
    ;;
  esac
done
IFS=$OLDIFS

RES=$(glmergefind "$@") &&
  set -- glmergerev &&
  if [ "$ACCEPT_MERGE" -eq 1 ]; then
    set -- "$@" -m
  fi &&
  printf '%s' "$RES" | glpick -M |
  xargs "$@"
