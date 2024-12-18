#!/bin/bash

set -e

clear

function setCons {
    tput smul
    tput bold
    tput setaf 123
}

declare -a CMDS=(
    'yum update'
    'cd /etc'
    'git show HEAD'
    'cd /'  # needed for find to function as expected (expands wildcards before execution)
    'find /etc -name "*.bak" -o -name "*.rpmsave" -o -name "*.rpmnew" -o -name "*.rpmorig"'
    'find /srv -name "*.bak" -o -name "*.rpmsave" -o -name "*.rpmnew" -o -name "*.rpmorig"'
    'find /sys -name "*.bak" -o -name "*.rpmsave" -o -name "*.rpmnew" -o -name "*.rpmorig"'
    'find /usr -name "*.bak" -o -name "*.rpmsave" -o -name "*.rpmnew" -o -name "*.rpmorig"'
    'find /var/lib -name "*.bak" -o -name "*.rpmsave" -o -name "*.rpmnew" -o -name "*.rpmorig"'
    'yum list installed > /root/installed_packets'
)

CWD=$(pwd)

for CMD in "${CMDS[@]}"; do
    if [[ ! $CMD == "cd "* ]]; then
        # show every command except the helper directory changes
        echo
        echo
        setCons
        echo "Running $CMD…"
        echo
        tput sgr0
    fi
    $CMD
done

cd $CWD

echo
echo

