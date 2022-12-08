#!/bin/bash

if [ ! -x /usr/bin/flatpak ]; then
    echo "flatpak seems not to be installed – nothing to update"
    exit
fi

APPS=$(/usr/bin/flatpak list --app | tr [:space:] ' ' | tr -s ' ' | cut -d' ' -f2)

for APP in $APPS; do
    echo
    echo "--------------------------------------------------------------------------------"
    CMD="/usr/bin/flatpak update $APP"
    echo $CMD
    $CMD
done

echo
