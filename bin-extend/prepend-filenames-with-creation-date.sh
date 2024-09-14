#!/bin/bash

ls -l --color=auto --time-style=+' %Y-%m-%d\t%H-%M-%S ' | while read LINE; do
    FILENAME=$(echo $LINE | cut -d' ' -f7-)
    DATE=$(echo $LINE | cut -d' ' -f6)
    echo
    echo $LINE
    echo $FILENAME
    echo $DATE
    NEW=$DATE'__'$FILENAME
    mv "$FILENAME" "$NEW"
done
