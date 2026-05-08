#!/bin/bash

# let the script exit on errors (even within pipes), check for unset vars and disable globbing
# see https://sipb.mit.edu/doc/safe-shell
set -euf -o pipefail

echo

if [ "$#" -ne 1 ]; then
	echo "ERROR:"
	echo "Either .sql or .sql.bz2 file has to be given"
	exit 1
fi

if [ ! -e $1 ]; then
    echo "ERROR:"
    echo "$1 does not exist. Exiting…"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "ERROR:"
    echo "$1 is not a file. Exiting…"
    exit 1
fi

# get the database env
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# create the dump file in temp directory
if [[ "$1" == *.sql.bz2 ]]; then
	CAT_CMD="bzcat $1"

elif [[ "$1" == *.sql ]]; then
	CAT_CMD="cat $1"

elif [[ $1 == "-h" || $1 == "--help" ]]; then
	echo "Usage: $0 dumpfile"
	echo
	echo "       dumpfile has to be a *.sql or a *.sql.bz2 file"
	echo
	exit 0

else
	echo "ERROR:"
	echo "Either .sql or .sql.bz2 file has to be given"
	exit 1

fi

# restore the database
DATABASE=$(echo $1 | rev | cut -d'_' -f 1 | rev | cut -d'.' -f 1)

echo "Restoring database $DATABASE…"
$CAT_CMD | mariadb -D $DATABASE

echo "Success"

echo
exit 0
