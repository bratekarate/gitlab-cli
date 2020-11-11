#!/bin/sh

glmergefind -i "$1" "$2" | xargs glmergerev
