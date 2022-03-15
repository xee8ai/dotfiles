#!/bin/bash

OUTFILE="/tmp/zero-yhT6iV46AchOM998"

dd if=/dev/zero of=$OUTFILE bs=1M
rm -f $OUTFILE
