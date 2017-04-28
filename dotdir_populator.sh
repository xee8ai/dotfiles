#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function usage_error {
	echo "Usage: $0 [install|update|full]"
	echo "Will now exit…"
	exit 1
}

if [ "$#" -ne 1 ]; then
	usage_error
fi

# process additional syntax files
SYNTAX_SRC_DIR="$DIR/vim_syntax_files"
SYNTAX_DEST_DIR="$HOME/.vim/syntax"
if ! test -e $SYNTAX_DEST_DIR; then
	mkdir -p $SYNTAX_DEST_DIR
fi
cd $SYNTAX_SRC_DIR
ls -- *.vim | while read SYNTAX_FILE; do
	# check if file already exists
	if ! test -e $SYNTAX_DEST_DIR/$SYNTAX_FILE; then
		echo "Copying $SYNTAX_FILE to $SYNTAX_DEST_DIR"
		cp $SYNTAX_FILE $SYNTAX_DEST_DIR
	fi
	# check if sha1 hashes differ
	if [ `sha1sum $SYNTAX_DEST_DIR/$SYNTAX_FILE | awk '{print $1}'` != `sha1sum $SYNTAX_FILE | awk '{print $1}'` ] ; then
		echo "Replacing $SYNTAX_FILE in $SYNTAX_DEST_DIR"
		cp $SYNTAX_FILE $SYNTAX_DEST_DIR
	fi
done
cd $DIR

case "$1" in
	install)
		$DIR/populate_dotvim.py install
		$DIR/populate_mybash.py install
		$DIR/populate_gitignore_templates.py install
		;;
	update)
		$DIR/populate_dotvim.py update
		$DIR/populate_mybash.py update
		$DIR/populate_gitignore_templates.py update
		;;
	full)
		$DIR/populate_dotvim.py install
		$DIR/populate_dotvim.py update
		$DIR/populate_mybash.py install
		$DIR/populate_mybash.py update
		$DIR/populate_gitignore_templates.py install
		$DIR/populate_gitignore_templates.py update
		;;
	*)
		usage_error
		;;
esac
