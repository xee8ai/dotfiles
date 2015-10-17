#!/bin/bash

HOMEDIR=$HOME
BUNDLEDIR=$HOMEDIR/.vim/bundle
DIRS=".vim
.vim/autoload
.vim/bundle"

CURDIR=$(pwd)

echo


################################################################################
function make_dirs {
	echo "Making dirs…"
	echo "------------"
	# make dirs
	for DIR in $DIRS; do
		echo $DIR
		if ! test -e $HOMEDIR/$DIR; then
			mkdir $HOMEDIR/$DIR
		fi
	done
	echo
}


################################################################################
function get_pathogen {
	# get pathogen
	if test -e $HOMEDIR/.vim/autoload; then
		echo "Getting pathogen…"
		echo "-----------------"
		echo
		curl -LSso $HOMEDIR/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	fi
}


################################################################################
function get_plugins {
	# get plugins
	cd $BUNDLEDIR
	echo "Cloning plugins…"
	echo "----------------"
	echo "emmet…"
	git clone https://github.com/mattn/emmet-vim.git
	echo "nerdtree…"
	git clone https://github.com/scrooloose/nerdtree.git
	echo "vim-nerdtree-tabs…"
	git clone https://github.com/jistr/vim-nerdtree-tabs.git
	echo "vim-surround…"
	git clone https://github.com/tpope/vim-surround.git
	echo "vim-commentary…"
	git clone https://github.com/tpope/vim-commentary.git
	echo
}


################################################################################
function update_plugins {
	cd $BUNDLEDIR
	echo "Updating plugins…"
	echo "-----------------"
	ls -D | while read DIR; do
		cd $DIR
		echo "$DIR…"
		git pull
		cd $HOMEDIR/.vim/bundle
	done
}


################################################################################
################################################################################
case "$1" in
	install)
		make_dirs
		get_pathogen
		get_plugins
		;;
	update)
		get_pathogen
		update_plugins
		;;
	*)
		echo "Usage: $0 [install|update]"
		cd $CURDIR
		exit 1
		;;
esac

cd $CURDIR
exit 0
