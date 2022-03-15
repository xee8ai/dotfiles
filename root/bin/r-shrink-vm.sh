#!/bin/bash

echo

if [ "$#" -ne 1 ]; then
	echo "ERROR: No image path given"
	echo "Usage: $0 PATH_TO_VM_IMAGE"
	echo
	return 1
fi

if [ ! -e $1 ]; then
	echo "ERROR: Path $1 does not exist"
	echo
	exit 1
fi

if [ ! -f $1 ]; then
	echo "ERROR: Path $1 is not a file"
	echo
	exit 1
fi

VM=$1

CMD="qemu-img convert $VM -O qcow2 $VM.tmp"
echo $CMD
$CMD
echo

CMD="mv -f $VM.tmp $VM"
echo $CMD
$CMD
echo

CMD="chmod 600 $VM"
echo $CMD
$CMD
echo
