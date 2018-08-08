#!/bin/bash

SRC_DIR="$HOME/src"
VIM_SRC_DIR="$SRC_DIR/vim"

cd $SRC_DIR

if [ ! -d $VIM_SRC_DIR ]; then
	git clone https://github.com/vim/vim.git
	cd $VIM_SRC_DIR
else
	cd $VIM_SRC_DIR
	git pull
fi

cd $VIM_SRC_DIR/src

# see ./configure --help for available options
./configure --enable-cscope --enable-gui=no --enable-luainterp=yes --enable-multibyte --enable-python3interp --enable-rubyinterp=yes --enable-tclinterp=yes --prefix=/root/.local/vim --with-features=huge --with-tlib=ncurses --without-x

make && make install
