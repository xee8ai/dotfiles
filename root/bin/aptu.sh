#!/bin/bash

set -e

# Workaround for not compatible RP version
#echo "Reinstalling RequestPolicy…"
#/root/bin/r-reinstall_requestpolicy.sh

LOGPATH="/root/log"

function setCons {
	tput smul
	tput bold
	tput setaf 123
}

if [ -n "$1" ]; then
	DLLIMIT=" -o Acquire::http::DL-Limit=100"
else
	DLLIMIT=""
fi

# CMD="apt-get purge ~c"
# echo
# setCons
# echo $CMD…
# tput sgr0
# $CMD

# CMD="apt-get purge ~o"
# echo
# setCons
# echo $CMD…
# tput sgr0
# $CMD

CMD="apt-get autoremove"
echo
setCons
echo $CMD…
tput sgr0
$CMD

CMD="nice -n 10$DLLIMIT apt-get update"
echo
setCons
echo $CMD…
tput sgr0
$CMD

CMD="nice -n 10 apt-get$DLLIMIT dist-upgrade"
echo
setCons
echo $CMD…
tput sgr0
$CMD

# apt-get upgrade in testing oft gebraucht (wenn gerade wieder Abhängigkeiten nicht erfüllt sind…)
CMD="nice -n 10 apt-get$DLLIMIT upgrade"
echo
setCons
echo $CMD…
tput sgr0
$CMD

CMD="apt-get autoclean"
CMD="apt-get clean"
echo
setCons
echo $CMD…
tput sgr0
$CMD

CMD="apt autoremove"
echo
setCons
echo $CMD…
tput sgr0
$CMD

CMD="/root/bin/installed_packets.sh"
echo
setCons
echo $CMD…
tput sgr0
$CMD

CMD="/root/bin/search_for_missing_packets.sh"
echo
setCons
echo $CMD…
tput sgr0
#echo "… deactivated"
/root/bin/search_for_missing_packets.sh

echo
