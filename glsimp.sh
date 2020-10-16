#!/bin/sh

jq "$@" 'def form: if has("n") then {n} else null end + {id,name,web_url}; if type == "array" then [ .[] | form ] else form end'
