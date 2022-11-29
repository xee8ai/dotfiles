#!/bin/bash

GIT="/usr/bin/git"
MKDIR="/usr/bin/mkdir"
RSYNC="/usr/bin/rsync"

DRY_RUN=""
RSYNC_OPTIONS="-avrpEl --delete-excluded"$DRY_RUN

# store sources in array because of the spaces
declare -A SRCS
SRCS[0]="/var/lib/dokuwiki/acl"
SRCS[1]="--exclude cache /var/lib/dokuwiki/data"

GITDIR="/root/backups/dokuwiki_git"
DSTDIR=$GITDIR"/dokuwiki"

function run {
    CMD=$1
    echo
    tput smul; tput bold; tput setaf 123
    echo $CMD
    tput sgr0
    $CMD
}

if [ ! -d $DSTDIR ]; then
    clear
    echo
    echo "ERROR"
    echo "-----"
    echo "Destination directory $DSTDIR does not exist. Do something like:"
    echo "  – $MKDIR -p $DSTDIR"
    echo "  – cd $GITDIR"
    echo "  – $GIT init"
    echo "  – maybe create .gitignore and .ctags"
    echo "  – $GIT add ."
    echo "  – $GIT commit -m 'Initial commit'"
    echo "  – $0"
    echo
    exit 1
fi

for SRC in "${SRCS[@]}"; do
    CMD="$RSYNC $RSYNC_OPTIONS $SRC $DSTDIR"
    run "$CMD"
done

echo
cd $GITDIR

$GIT add .
$GIT commit -m "Autobackup by $0 at $(date -Iseconds)."
