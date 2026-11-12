#!/bin/bash

foreground_and_background_side_by_side() {
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
}

colors_on_solarized_bg() {
    for ((a=0;a<32;a++)); do
        echo
        for ((b=0;b<8;b++)); do
            echo -n "  "
            let code=($a * 8 + $b)
            tput setaf $code

            tput setab 8
            printf " %0*d " 3 $code

            tput setab 15
            printf " %0*d " 3 $code

            tput bold
            tput setab 8
            printf " %0*d " 3 $code

            tput setab 15
            printf " %0*d " 3 $code

            tput sgr0
        done
    done
}

echo
foreground_and_background_side_by_side

echo
echo
echo
colors_on_solarized_bg

echo
echo
echo
echo "Use the above values in “tput setaf COLORCODE” (foreground) and “tput setab COLORCODE” (background)"
echo
