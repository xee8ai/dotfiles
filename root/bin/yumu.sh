#!/bin/bash

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
        'find /etc -name *rpmsave'
        'find /etc -name *rpmnew'
        'find /etc -name *rpmorig'
)

for CMD in "${CMDS[@]}"; do
        echo
        echo
        echo "----------------------------------------------------------------"
		setCons
        echo "Running $CMD…"
		tput sgr0
        echo "----------------------------------------------------------------"
        $CMD
done

echo
echo

