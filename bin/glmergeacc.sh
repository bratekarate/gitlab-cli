#!/bin/sh

glbody "projects/$1/merge_requests/$2/merge?merge_when_pipeline_succeeds=true" \
  -X PUT
