#!/bin/bash

# Opens files from given git commit in vim tabs
# If no commit is given open files from most current one

if [ "$#" -lt 1 ]; then
    COMMIT="HEAD"
else
    COMMIT=$1
fi

RAW=$(git show --name-only --pretty="format:" $COMMIT | grep -v "Your git identity is: " | grep -v -e '^$')

OUT="vim"
let COUNT=0

echo

for F in $RAW; do
    echo $F
    let COUNT=$COUNT+1
    OUT="$OUT $F"
done

echo "$COUNT file(s)"

echo
echo
echo $OUT
echo
