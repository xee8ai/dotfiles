#!/bin/bash

IP4=$(iptables -nL | grep -c "policy DROP")
IP6=$(ip6tables -nL | grep -c "policy DROP")
STATUS="OK"

echo
echo "Checking firewall settings…"

if test $IP4 -ne 3; then
	echo
	echo "Problem with iptables:"
	echo "======================"
	iptables -nL
	STATUS="ERROR"
	echo
fi

if test $IP6 -ne 3; then
	echo
	echo "Problem with ip6tables:"
	echo "======================="
	ip6tables -nL
	STATUS="ERROR"
	echo
fi

echo $STATUS
echo
