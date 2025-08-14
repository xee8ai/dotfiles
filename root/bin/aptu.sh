#!/bin/bash

set -euo pipefail

APT="/usr/bin/apt"
# APTGET="/usr/bin/apt-get"
# APTITUDE="/usr/bin/aptitude"
FIND="/usr/bin/find"
NICE="/usr/bin/nice"

LOGPATH="/tmp"
LOGFILE=$LOGPATH"/root-aptu__"$(date -Iseconds)".log"
mkdir -p $LOGPATH
TEE=" 2>&1 | tee -a $LOGFILE"

function setCons {
    tput smul
    tput bold
    tput setaf 123
}

function logAndRun {
    CMD=$1
    echo
    setCons
    echo "$(hostname): $CMD…"
    echo "" >> $LOGFILE
    echo "----------------------------------------" >> $LOGFILE
    echo "$(date -Iseconds)" >> $LOGFILE
    echo "$CMD" >> $LOGFILE
    echo "--------------------" >> $LOGFILE
    tput sgr0
    eval $CMD$TEE
}

CMD="$APT autoremove"
logAndRun "$CMD"

CMD="$APT purge ~c"
logAndRun "$CMD"

CMD="$APT purge ~o"
logAndRun "$CMD"

CMD="$APT autoremove"
logAndRun "$CMD"

CMD="$NICE -n 10 $APT update"
logAndRun "$CMD"

CMD="$NICE -n 10 $APT dist-upgrade"
logAndRun "$CMD"

# apt-get upgrade in testing oft gebraucht (wenn gerade wieder Abhängigkeiten nicht erfüllt sind…)
CMD="$NICE -n 10 $APT upgrade"
logAndRun "$CMD"

CMD="$APT autoclean"
logAndRun "$CMD"

CMD="$APT clean"
logAndRun "$CMD"

CMD="$APT autoremove"
logAndRun "$CMD"

CMD="/root/bin/installed_packets.sh"
logAndRun "$CMD"

if [ -x /root/bin/update-flatpaks.sh ]; then
    CMD="/root/bin/update-flatpaks.sh"
    logAndRun "$CMD"
fi

if [ -x /root/bin/search_for_missing_packets.sh ]; then
    CMD="/root/bin/search_for_missing_packets.sh"
    logAndRun "$CMD"
fi

CWD=$(pwd)

FINDDIRS="
/etc
/srv
/sys
/usr
/var/lib
"
for FINDDIR in $FINDDIRS; do
    CMD='cd / && '$FIND' '$FINDDIR' -name "*.dpkg-*" -o -name "*.ucf-*" -o -name "*.old" -o -name "*.merge-error"'
    logAndRun "$CMD"
done

if [ -s /etc/apt/preferences.d/apt-listbugs ]; then
    echo
    setCons
    echo "The following packets are held back by apt-listbugs:"
    tput sgr0
    cat /etc/apt/preferences.d/apt-listbugs
fi

cd $CWD

echo
