#!/bin/bash

function usage {
	echo
	echo "Usage: $0 [a|accept|d|drop]"
	echo
}

if [ $# -ne 1 ]; then
	usage
	exit 1
fi


case "$1" in
	a | accept )
		POLICY="ACCEPT"
		;;
	d | drop )
		POLICY="DROP"
		;;
	*)
		usage
		exit 1
		;;
esac

IPTABLES='/sbin/iptables'

echo
CMD="$IPTABLES -P OUTPUT $POLICY"
echo $CMD
$CMD
echo
echo "$IPTABLES -nL | grep OUTPUT"
$IPTABLES -nL | grep OUTPUT
echo
