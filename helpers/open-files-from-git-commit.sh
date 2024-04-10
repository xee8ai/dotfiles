#!/bin/bash

# Opens files from given git commit in vim tabs
# If no commit is given open files from most current one

if [ "$#" -lt 1 ]; then
    COMMIT="HEAD"
else
    COMMIT=$1
fi

vim -p $(git show --name-only --pretty="format:" $COMMIT | grep -v "Your git identity is: " | grep -v -e '^$')
