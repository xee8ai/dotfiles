#!/bin/bash


for c in {0..255}; do
    tput bold
    tput setaf $c
    # tput setaf $c | cat -v
    MOD=$(($c % 8))
    if [ "${MOD}" -eq 0 ]; then
        echo
    fi
    if [ "$c" -lt 100 ]; then
        echo -n " "
    fi
    if [ "$c" -lt 10 ]; then
        echo -n " "
    fi
    echo -n "      $c "
    tput setab $c
    echo -n "    "

    tput sgr0
done


echo
echo
echo "Use the above values in “tput setaf COLORCODE” (foreground) and “tput setab COLORCODE” (background)"
echo
