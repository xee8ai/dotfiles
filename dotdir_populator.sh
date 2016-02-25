#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function usage_error {
	echo "Usage: $0 [install|update]"
	echo "Will now exit…"
	exit 1
}

if [ "$#" -ne 1 ]; then
	usage_error
fi

case "$1" in
	install)
		$DIR/populate_dotvim.py install
		$DIR/populate_mybash.py install
		;;
	update)
		$DIR/populate_dotvim.py update
		$DIR/populate_mybash.py update
		;;
	*)
		usage_error
		;;
esac
