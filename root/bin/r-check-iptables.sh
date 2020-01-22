#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

IP4=$(iptables -nL | grep -c "policy DROP")
IP6=$(ip6tables -nL | grep -c "policy DROP")

STATUS="${GREEN}OK${NC}"

echo
echo "Checking firewall settings…"

if test $IP4 -ne 3; then
	echo
	echo "Problem with iptables:"
	echo "======================"
	iptables -nL
	STATUS="${RED}ERROR${NC}"
	echo
fi

if test $IP6 -ne 3; then
	echo
	echo "Problem with ip6tables:"
	echo "======================="
	ip6tables -nL
	STATUS="${RED}ERROR${NC}"
	echo
fi

echo -e $STATUS
echo
