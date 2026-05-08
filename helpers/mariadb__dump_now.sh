#!/bin/bash

# exit on first error
# set -e
set -euf -o pipefail

umask 027

# set databases
# do not change the format here; parsed by mariadb__dump_by_cron.py
DATABASES="
database_1
database_2
"

DSTDIR="/root/db_dumps/manually"
LSDIR="/path/to/your/project"

if ! test -e $LSDIR; then
	DESC="default"
else
    cd $LSDIR
    if ! test -e .git; then
        DESC="default"
    else
        DESC=$(git branch | grep "*" | cut -c 3- | tr '/' '__')
    fi
fi

mkdir -p $DSTDIR

if [ $# -eq 1 ] ; then
    # overwrite default description
    DESC=$1
elif [ $# -eq 2 ]; then
    # overwrite default description
    DESC=$1
    # overwrite default destination directory
	DSTDIR=$2
elif [ $# -gt 2 ]; then
    echo
    echo "Usage:"
    echo "$0 [DESCRIPTION [DIRECTORY]]"
    echo
    exit 1
fi

if [ ! -e $DSTDIR ]; then
    echo
	echo "ERROR: $DSTDIR does not exists"
    echo
	exit 1
fi

if [ ! -d $DSTDIR ]; then
    echo
	echo "ERROR: $DSTDIR is not a directory"
    echo
	exit 1
fi

TIMESTAMP=$(date -Iseconds)

for DATABASE in $DATABASES; do
    echo "Dumping $DATABASE…"
    DUMPFILE="$DSTDIR/"$TIMESTAMP"___"$DESC"___"$DATABASE".sql.bz2"
    /usr/bin/mariadb-dump $DATABASE | bzip2 > $DUMPFILE
done
