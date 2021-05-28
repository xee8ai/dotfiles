#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# store result in this file; can be used e.g. for icinga checks
CHECKFILE="/tmp/root-iptables_check_state"

date -u -Iseconds > $CHECKFILE

IP4=$(/usr/sbin/iptables -nL | grep -c "policy DROP")
IP6=$(/usr/sbin/ip6tables -nL | grep -c "policy DROP")

echo
echo "Checking packet filter…"

if test $IP4 -ne 3; then
	echo
	echo "Problem with iptables:"
	echo "======================"
	/usr/sbin/iptables -nL
	COLOR=$RED
	STATUS="ERROR"
	CODE=1
	echo
elif test $IP6 -ne 3; then
	echo
	echo "Problem with ip6tables:"
	echo "======================="
	/usr/sbin/ip6tables -nL
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
