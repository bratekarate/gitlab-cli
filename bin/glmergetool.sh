#!/bin/sh


RES=$(glmergefind "$@") &&
  printf '%s' "$RES" | glpick M |
  xargs glmergerev

