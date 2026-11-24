#!/bin/bash

set -euo pipefail

# Manually installed .deb packages (and their dependencies) to exclude from ~o
keep_packages=(
    geteduroam-gui
    teams
    zoom
)

APT="/usr/bin/apt"
# APTGET="/usr/bin/apt-get"
# APTITUDE="/usr/bin/aptitude"
FIND="/usr/bin/find"
NICE="/usr/bin/nice"

LOGPATH="/tmp"
LOGFILE=$LOGPATH"/root-aptu__"$(date -Iseconds)".log"
mkdir -p $LOGPATH
TEE=" 2>&1 | tee -a $LOGFILE"

function setCons {
    tput smul
    tput bold
    tput setaf 39
}

function logAndRun {
    CMD=$1
    CMDPRINT="${1:0:120}"
    echo
    setCons
    echo "$(hostname): $CMDPRINT…"
    echo "" >> $LOGFILE
    echo "----------------------------------------" >> $LOGFILE
    echo "$(date -Iseconds)" >> $LOGFILE
    echo "${CMD}" >> $LOGFILE
    echo "--------------------" >> $LOGFILE
    tput sgr0
    eval $CMD$TEE
}

purge_obsolete() {
    local -a installed_keeps=()
    local pkg
    for pkg in ${keep_packages[@]+"${keep_packages[@]}"}; do
        if dpkg-query -W -f='${Status}\n' "$pkg" 2>/dev/null | grep -q '^install ok installed$'; then
            installed_keeps+=("$pkg")
        fi
    done

    local pattern='~o'
    if (( ${#installed_keeps[@]} > 0 )); then
        local protected_pkgs
        protected_pkgs=$(
            LC_ALL=C apt-cache depends --recurse --important --installed "${installed_keeps[@]}" |
                awk '
            { pkg = "" }
            /^[^[:space:]|]/ { pkg = $1 }
            /^[[:space:]|]*(Pre)?Depends:/ { pkg = $2 }
            pkg != "" && pkg !~ /^</ {
                sub(/:.*/, "", pkg)
                print pkg
            }
        ' | sort -u
    )

    for pkg in $protected_pkgs; do
        pattern+=" !?exact-name(${pkg})"
    done
    fi

    CMD='apt purge "'$@'" "'$pattern'"'
    logAndRun "$CMD"
}


CMD="$APT autoremove"
logAndRun "$CMD"

CMD="$APT purge ~c"
logAndRun "$CMD"

purge_obsolete

CMD="$APT autoremove"
logAndRun "$CMD"

CMD="$NICE -n 10 $APT update"
logAndRun "$CMD"

CMD="$NICE -n 10 $APT dist-upgrade"
logAndRun "$CMD"

# apt-get upgrade in testing oft gebraucht (wenn gerade wieder Abhängigkeiten nicht erfüllt sind…)
CMD="$NICE -n 10 $APT upgrade"
logAndRun "$CMD"

CMD="$APT autoclean"
logAndRun "$CMD"

CMD="$APT clean"
logAndRun "$CMD"

CMD="$APT autoremove"
logAndRun "$CMD"

CMD="/root/bin/installed_packets.sh"
logAndRun "$CMD"

if [ -x /root/bin/update-flatpaks.sh ]; then
    CMD="/root/bin/update-flatpaks.sh"
    logAndRun "$CMD"
fi

if [ -x /root/bin/search_for_missing_packets.sh ]; then
    CMD="/root/bin/search_for_missing_packets.sh"
    logAndRun "$CMD"
fi

if [ -x /usr/bin/fwupdmgr ]; then
    CMD="/usr/bin/fwupdmgr update"
    logAndRun "$CMD"
fi

CWD=$(pwd)

FINDDIRS="
/etc
/srv
/sys
/usr
/var/lib
"
for FINDDIR in $FINDDIRS; do
    CMD='cd / && '$FIND' '$FINDDIR' -name "*.dpkg-*" -o -name "*.ucf-*" -o -name "*.old" -o -name "*.merge-error"'
    logAndRun "$CMD"
done

if [ -s /etc/apt/preferences.d/apt-listbugs ]; then
    echo
    setCons
    echo "The following packets are held back by apt-listbugs:"
    tput sgr0
    cat /etc/apt/preferences.d/apt-listbugs
fi

/usr/sbin/needrestart

cd $CWD

echo
