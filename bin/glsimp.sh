#!/bin/sh

# TODO: currently only usasble for project. use getopts to specify what type of
# object to simplify and use project as default.

jq "$@" 'def form: if has("n") then {n} else null end + {id,name,path_with_namespace,web_url,ssh_url_to_repo}; if type == "array" then [ .[] | form ] else form end'
