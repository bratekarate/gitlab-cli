#!/bin/sh

glsearch_pages "$@" |
  tail -n 1 |
  jq -r 'if type == "array" then to_entries | [ .[] | {n: .key} + .value ] else . end'
