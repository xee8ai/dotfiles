#!/bin/bash

if [ ! -x $FLATPAK ]; then
    echo "flatpak seems not to be installed"
    exit 1
fi

APPS=$(flatpak list --app | tr [:space:] ' ' | tr -s ' ' | cut -d' ' -f2)

for APP in $APPS; do
    echo
    echo "--------------------------------------------------------------------------------"
    CMD="flatpak update $APP"
    echo $CMD
    $CMD
done

echo
