#!/usr/bin/env bash
# why_is_load_high.sh - find out what causes load when the CPU looks idle.
#
# Usage:
#   sudo ./why_is_load_high.sh [snapshot] [SECONDS]      one-off analysis (default 10 s)
#   sudo ./why_is_load_high.sh watch [THRESHOLD] [LOG]   wait for load1 > THRESHOLD (default 4),
#                                               then append a snapshot to LOG
#                                               (default /var/log/why_is_load_high.log)
#
# Optional packages (Debian): apt install sysstat    (iostat, pidstat)
# Everything else uses procfs/procps/util-linux, which are already installed.
# Linux load = tasks in state R (runnable) + D (uninterruptible, mostly I/O wait).
# The core of this script samples those tasks repeatedly and reports the
# AVERAGE NUMBER of tasks per process/state/kernel wait function, i.e. how many
# "load points" each one contributes.

set -u
export LC_ALL=C

have() { command -v "$1" >/dev/null 2>&1; }
hdr()  { printf '\n===== %s =====\n' "$*"; }

[ "$(id -u)" -eq 0 ] || echo "WARNING: not root - wchan, dmesg and per-process I/O will be incomplete." >&2

snapshot() {
    local secs=${1:-10}
    local interval=0.5
    local n; n=$(awk -v s="$secs" -v i="$interval" 'BEGIN{print int(s/i)}')
    [ "$n" -ge 1 ] || n=1
    local cpus; cpus=$(nproc)

    echo "why_is_load_high snapshot  $(date '+%F %T')  host=$(hostname)  cpus=$cpus  sample=${secs}s"

    hdr "Load average (1/5/15) and current run/blocked counts"
    cat /proc/loadavg
    awk '/^procs_running/{r=$2} /^procs_blocked/{b=$2} END{printf "procs_running=%s  procs_blocked(D, I/O wait)=%s\n", r, b}' /proc/stat

    hdr "Pressure stall info (PSI): share of time tasks were stalled"
    if [ -r /proc/pressure/cpu ]; then
        for f in cpu io memory; do printf '%-7s' "$f"; head -1 /proc/pressure/$f; done
        echo "(some avg10 >> 0 for io/memory => that resource is the bottleneck)"
    else
        echo "PSI not available on this kernel."
    fi

    # Start background collectors so they cover the same window as the sampler.
    local tmp; tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN
    vmstat 1 "$secs" >"$tmp/vmstat" 2>&1 &
    have iostat  && iostat -xz 1 "$secs" >"$tmp/iostat" 2>&1 &
    have pidstat && pidstat -d -h 1 "$secs" >"$tmp/pidstat" 2>&1 &
    local f1 f2
    f1=$(awk '/^processes/{print $2}' /proc/stat)

    # Core sampler: record state/comm/wchan of every R and D task.
    for ((i = 0; i < n; i++)); do
        ps -eo state=,comm=,wchan:32= 2>/dev/null | awk '
            ($1=="R" || $1=="D") {
                comm=$2; for (k=3;k<NF;k++) comm=comm" "$k
                if (comm=="ps" || comm=="awk") next      # ignore ourselves
                print $1 "\t" comm "\t" $NF
            }'
        sleep "$interval"
    done >"$tmp/samples"
    wait
    f2=$(awk '/^processes/{print $2}' /proc/stat)

    hdr "WHO CONTRIBUTES LOAD  (avg tasks over $n samples; sum ~ load)"
    echo "-- by state --"
    awk -F'\t' -v n="$n" '{c[$1]++} END{
        printf "R (runnable/CPU)     %6.2f\n", c["R"]/n
        printf "D (blocked, I/O etc) %6.2f\n", c["D"]/n }' "$tmp/samples"
    echo
    echo "-- by process (state, avg tasks) --"
    awk -F'\t' -v n="$n" '{c[$1"\t"$2]++} END{for(k in c) printf "%6.2f\t%s\n", c[k]/n, k}' "$tmp/samples" \
        | sort -rn | head -15 | awk -F'\t' '{printf "%s  [%s] %s\n",$1,$2,$3}'
    echo
    echo "-- D-state tasks by kernel wait function (what they wait on) --"
    awk -F'\t' -v n="$n" '$1=="D"{c[$3]++} END{for(k in c) printf "%6.2f  %s\n", c[k]/n, k}' "$tmp/samples" | sort -rn | head -10
    echo "(hints: nfs*/rpc* = network FS; io_schedule/blk*/bio* = disk; jbd2*/ext4*/xfs* = filesystem/journal;"
    echo "        folio_wait*/wait_on_page* = page cache/swap; fuse* = FUSE mount; '-'/0 = unknown, run as root)"

    hdr "vmstat  (b=blocked  wa=iowait  si/so=swap  st=steal  cs=ctx switches)"
    cat "$tmp/vmstat"
    printf '\nProcess creation rate: %s forks/s' "$(( (f2 - f1) / secs ))"
    echo "  (hundreds/s sustained => cron/script fork storm)"

    hdr "Disk utilisation (iostat -xz)"
    if have iostat; then
        # print only the last (average-over-interval-ending) block
        awk '/^Device/{blk=""} {blk=blk $0 "\n"} END{printf "%s", blk}' "$tmp/iostat"
        echo "(%util near 100 or high await/aqu-sz => device saturated)"
    else
        echo "iostat missing -> apt install sysstat"
    fi

    hdr "Top processes by disk I/O (pidstat -d)"
    if have pidstat; then
        awk 'NR<=3 || $0 ~ /^#/ {print; next} NF>=8 && $4+$5>0 {print}' "$tmp/pidstat" | sort -k4,4nr -k5,5nr 2>/dev/null | head -12
    else
        echo "pidstat missing -> apt install sysstat"
    fi

    hdr "Memory / swap"
    free -h
    echo
    swapon --show 2>/dev/null || true

    hdr "Network filesystems (stat with 3 s timeout)"
    local found=0
    while read -r _ mp type _; do
        case "$type" in nfs*|cifs|smb3|fuse.sshfs|davfs|ceph|glusterfs)
            found=1
            if timeout 3 stat -t "$mp" >/dev/null 2>&1; then echo "OK      $mp ($type)"
            else echo "HUNG/SLOW  $mp ($type)  <-- likely cause of D-state load"; fi ;;
        esac
    done </proc/mounts
    [ $found -eq 1 ] || echo "none mounted"

    hdr "CPU limits / throttling (containers, cgroups)"
    local cg=/sys/fs/cgroup/cpu.stat
    [ -r "$cg" ] && grep -E 'nr_throttled|throttled_usec' "$cg" || echo "n/a"

    hdr "Recent kernel warnings (disk errors, resets, hung tasks, OOM)"
    if dmesg -T --level=err,warn 2>/dev/null | tail -15 | grep . ; then :; else echo "none visible (or need root)"; fi
    dmesg -T 2>/dev/null | grep -iE 'blocked for more than|hung task|reset|I/O error|oom' | tail -5

    hdr "Storage health hint"
    if have smartctl; then echo "smartctl present: run 'smartctl -H /dev/sdX' per disk"
    else echo "optional: apt install smartmontools"; fi

    echo
    echo "done."
}

watch_mode() {
    local thr=${1:-4} log=${2:-/var/log/why_is_load_high.log}
    echo "watching load1 > $thr, logging to $log (Ctrl-C to stop)"
    while :; do
        local l; l=$(cut -d' ' -f1 /proc/loadavg)
        if awk -v l="$l" -v t="$thr" 'BEGIN{exit !(l>t)}'; then
            snapshot 10 >>"$log" 2>&1
            sleep 60   # don't re-trigger continuously
        else
            sleep 5
        fi
    done
}

case "${1:-snapshot}" in
    snapshot) snapshot "${2:-10}" ;;
    watch)    watch_mode "${2:-4}" "${3:-/var/log/why_is_load_high.log}" ;;
    -h|--help|help) sed -n '2,13p' "$0" ;;
    [0-9]*)   snapshot "$1" ;;
    *)        echo "unknown mode: $1"; exit 2 ;;
esac
