#!/bin/bash

set -e

# Workaround for not compatible RP version
#echo "Reinstalling RequestPolicy…"
#/root/bin/r-reinstall_requestpolicy.sh

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

if [ -n "$1" ]; then
	DLLIMIT=" -o Acquire::http::DL-Limit=100"
else
	DLLIMIT=""
fi

# CMD="apt-get purge ~c"
# logAndRun "$CMD"

# CMD="apt-get purge ~o"
# logAndRun "$CMD"

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

CMD="/root/bin/search_for_missing_packets.sh"
logAndRun "$CMD"

echo
