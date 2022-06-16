#!/bin/bash

DIR="/root/installed_packets"

APTMARK="/usr/bin/apt-mark"
DPKG="/usr/bin/dpkg"
MKDIR="/usr/bin/mkdir"
TEST="/usr/bin/test"

if ! $TEST -e $DIR; then $MKDIR -p $DIR; fi

$DPKG --get-selections > $DIR/all_installed_packets.txt
$DPKG -l | grep "ii " > $DIR/all_installed_packets_versions.txt
$APTMARK showauto > $DIR/autoinstalled_packets.txt
$APTMARK showmanual > $DIR/manual_installed_packets.txt
