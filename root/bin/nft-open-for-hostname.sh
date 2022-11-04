#!/bin/bash

HOSTNAME="xeebook"

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 [open|close]"
fi

echo

NFT="/sbin/nft"
CUT="/usr/bin/cut"
GREP="/usr/bin/grep"
HEAD="/usr/bin/head"
SED="/usr/bin/sed"

TABLE="inet filter"
CHAIN="FWKNOP_INPUT"
COMMENT="nft-open-for-$HOSTNAME"

JOB=$1
IP=$2
PORTS=$3

PORTS=22


IPS=$(dig +short $HOSTNAME)
echo "Got the following IPs for $HOSTNAME:"
for IP in $IPS; do
    echo "  $IP"
done
echo

for IP in $IPS; do
    if [ "$JOB" == "open" ]; then
        CMD="$NFT add rule $TABLE $CHAIN ip saddr $IP tcp dport { $PORTS } accept comment \"$COMMENT\""
        echo "$CMD"
        $CMD
    elif [ "$JOB" == "close" ]; then
        HANDLE=$(nft -a list ruleset | $GREP $IP | $GREP $COMMENT | $CUT -d '#' -f2 | $SED 's/\s//g' | $SED 's/handle//g' | $HEAD -n 1)
        CMD="$NFT delete rule $TABLE $CHAIN handle $HANDLE"
        echo "$CMD"
        $CMD
    else
        exit 1
    fi
done

echo
