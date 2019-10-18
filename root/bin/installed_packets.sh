#!/bin/bash

DIR="/root/installed_packets"

if ! test -e $DIR; then mkdir -p $DIR; fi

dpkg --get-selections > $DIR/all_installed_packets.txt
apt-mark showauto > $DIR/autoinstalled_packets.txt
apt-mark showmanual > $DIR/manual_installed_packets.txt
