#!/bin/bash


if [ "$#" -ne 2 ]; then
        echo
        echo "Usage: $0 <USERNAME> <SLEEP_INTERVAL_IN_SEC>"
        echo
        exit 1
fi

USER=$1
SLEEP_INT=$2

NOW=$(date -Iseconds)
CSV_FILE="/tmp/cpu_usage_for_user_$1__$NOW.csv"
PNG_FILE="/tmp/cpu_usage_for_user_$1__$NOW.png"
PLOT_FILE="/tmp/cpu_usage_for_user_$1__$NOW.gnuplot"

echo
echo "Output goes to $CSV_FILE"
echo "End by pressing CTRL+C"
echo "Create a plot running “gnuplot $PLOT_FILE”"
echo
echo "time,CPU,RAM,Processes" > $CSV_FILE


# write the gnuplot script file
cat <<EOF>> $PLOT_FILE
set datafile separator ','
set xdata time
set timefmt "%Y-%m-%dT%H:%M:%S"
set key autotitle columnhead
set title "Resources used by user $USER, timing interval is $SLEEP_INT sec"
set ylabel "CPU and RAM usage"
set xlabel 'Time'
set ytics nomirror
set y2tics
set yrange [0:]
set y2range [0:]
set y2label "Process count"
set style line 100 lt 1 lc rgb "grey" lw 0.5
set grid ls 100
set ytics 10
set style line 101 lw 3 lt rgb "#ff0000"
set style line 102 lw 3 lt rgb "#0000ff"
set style line 103 lw 3 lt rgb "#ff00ff"

set xtics rotate # rotate labels on the x axis
set key outside right top

set term png size 1600,900
set output '$PNG_FILE'
plot '$CSV_FILE' using 1:2 with lines ls 101, '' using 1:3 with lines ls 102, '' using 1:4 with lines axis x1y2 ls 103
EOF


# collect data and write to csv forever
while true; do
        # https://stackoverflow.com/questions/12871090/how-to-calculate-cpu-utilization-of-a-process-all-its-child-processes-in-linux
        SUMMARY=$(top -b -d $SLEEP_INT -n 2 -u $USER | awk '$1 == "PID" {block_num++; next} block_num == 2 {cpu += $9; ram += $10; proc += 1} END {print cpu"_"ram"_"proc}')
        CPU_USAGE=$(echo $SUMMARY | cut -d"_" -f1)
        RAM_USAGE=$(echo $SUMMARY | cut -d"_" -f2)
        PROCESSES=$(echo $SUMMARY | cut -d"_" -f3)
        NOW=$(date -Iseconds)
        echo "$NOW,$CPU_USAGE,$RAM_USAGE,$PROCESSES" >> $CSV_FILE
        printf "\n%s   CPU:%4s%%   RAM:%4s%%   Processes:%6s" "$NOW" "$CPU_USAGE" "$RAM_USAGE" "$PROCESSES"
done
