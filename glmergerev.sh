#!/bin/sh

glmergediff "$1" "$2" |
  vim - &&
  P='y\(es\)\?' &&
  while ! echo "$A" | grep -iq "^\($P\|no\?\)$"; do
    printf 'Accept merge request? [y/n] ' &&
    read -r A
  done &&
  echo "$A" |  grep -iq "^$P$" &&
  glmergeacc 449 1
