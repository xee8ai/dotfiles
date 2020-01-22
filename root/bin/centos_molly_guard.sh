#!/bin/bash

# at Debian simply “apt-get install molly-guard” instead :-)

# at CentOS add aliases to your need, e.g.
# alias poweroff='/root/bin/centos_molly_guard.sh poweroff'

RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo
echo "ATTENTION:"
echo
echo -e "Do you really want to ${RED}$1 $(hostname)${NC}??"
echo
echo
echo "If so, use $(which $1) instead…"
echo
echo
exit 1
