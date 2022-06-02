#!/bin/bash

set -euo pipefail

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
	echo $CMD…
	echo "" >> $LOGFILE
	echo "----------------------------------------" >> $LOGFILE
	echo "$(date -Iseconds)" >> $LOGFILE
	echo "$CMD" >> $LOGFILE
	echo "--------------------" >> $LOGFILE
	tput sgr0
	eval $CMD$TEE
}

if [ "$#" -eq 0 ]; then
	DLLIMIT=""
elif [ "$#" -eq 1 ]; then
	if [ -n "$1" ]; then
		DLLIMIT=" -o Acquire::http::DL-Limit=100"
	fi
else
	echo "Too much arguments"
	exit 1
fi

CMD="aptitude purge ~c"
logAndRun "$CMD"

CMD="aptitude purge ~o"
logAndRun "$CMD"

CMD="apt-get autoremove"
logAndRun "$CMD"

CMD="nice -n 10$DLLIMIT apt-get update"
logAndRun "$CMD"

CMD="nice -n 10 apt-get$DLLIMIT dist-upgrade"
logAndRun "$CMD"

# apt-get upgrade in testing oft gebraucht (wenn gerade wieder Abhängigkeiten nicht erfüllt sind…)
CMD="nice -n 10 apt-get$DLLIMIT upgrade"
logAndRun "$CMD"

CMD="apt-get autoclean"
logAndRun "$CMD"

CMD="apt-get clean"
logAndRun "$CMD"

CMD="apt autoremove"
logAndRun "$CMD"

CMD="/root/bin/installed_packets.sh"
logAndRun "$CMD"

# CMD="/root/bin/search_for_missing_packets.sh"
# logAndRun "$CMD"

CMD='cd / && find /etc -name "*.dpkg-*" -o -name "*.ucf-*" -o -name "*.old"'
logAndRun "$CMD"

echo
