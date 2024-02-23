#!/bin/bash

NFT="/sbin/nft"
CUT="/usr/bin/cut"
GREP="/usr/bin/grep"
HEAD="/usr/bin/head"
SED="/usr/bin/sed"

TABLE="inet xee-filter"
CHAIN="FWKNOP_INPUT"
COMMENT="FWKNOP_CREATED_RULE"

JOB=$1
IP=$2
PORTS=$3

if [ "$JOB" == "open" ]; then
    CMD="$NFT add rule $TABLE $CHAIN ip saddr $IP tcp dport { $PORTS } accept comment \"$COMMENT\""
    $CMD
elif [ "$JOB" == "close" ]; then
    HANDLE=$($NFT -a list ruleset | $GREP $IP | $GREP $COMMENT | $CUT -d '#' -f2 | $SED 's/\s//g' | $SED 's/handle//g' | $HEAD -n 1)
    CMD="$NFT delete rule $TABLE $CHAIN handle $HANDLE"
    $CMD
else
    exit 1
fi
