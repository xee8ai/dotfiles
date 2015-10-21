#!/bin/bash
for t in `seq 1 6`; do
	setleds +num < /dev/tty$t > /dev/null
done
