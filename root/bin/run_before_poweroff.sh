#!/bin/bash

killall clementine
killall keepassxc
sleep 2

/root/bin/rotate_users_xsession-errors.sh
