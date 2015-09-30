#!/bin/bash

HOMEDIR=$HOME
DIRS=".vim
.vim/autoload
.vim/bundle"

CURDIR=$(pwd)

echo

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

cd $HOMEDIR/.vim/autoload

# get pathogen
echo "Getting pathogen…"
echo "-----------------"
curl -LSso $HOMEDIR/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
echo

# get plugins
cd $HOMEDIR/.vim/bundle
echo "Cloning plugins…"
echo "----------------"
git clone https://github.com/mattn/emmet-vim.git
git clone https://github.com/scrooloose/nerdtree.git
git clone https://github.com/jistr/vim-nerdtree-tabs.git
echo

cd $CURDIR
