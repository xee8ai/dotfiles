#!/bin/bash

# use “-iname” for case insensitive search
find /tmp -iname *.pdf | while read FILETOSHRED
do
	echo "Shredding $FILETOSHRED…"
	shred -n 5 -u -z $FILETOSHRED
done
