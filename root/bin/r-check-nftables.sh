#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# store result in this file; can be used e.g. for icinga checks
CHECKFILE="/tmp/root-packetfilter_check_state"

date -u -Iseconds > $CHECKFILE

DROPCOUNT=$(/sbin/nft list ruleset | grep -ic "policy drop")

echo
echo "Checking packet filter…"

if test $DROPCOUNT -ne 1; then
        echo
        echo "Problem with nftables:"
        echo "======================"
        /sbin/nft list ruleset
        COLOR=$RED
        STATUS="ERROR"
        CODE=1
        echo
else
        COLOR=$GREEN
        STATUS="OK"
        CODE=0
fi

echo $STATUS >> $CHECKFILE

OUTSTATUS="${COLOR}${STATUS}${NC}"
echo -e $OUTSTATUS
echo

exit $CODE
