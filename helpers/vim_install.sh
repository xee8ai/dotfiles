#!/bin/bash

# needs the following packages:
# yum install python3-devel gcc-c++ ncurses-devel

SRC_DIR="$HOME/src"
VIM_SRC_DIR="$SRC_DIR/vim"

DST_DIR="$HOME/.local"
VIM_DST_DIR="$DST_DIR/vim"

if [ ! -d $SRC_DIR ]; then
	mkdir -p $SRC_DIR
fi

if [ ! -d $DST_DIR ]; then
	mkdir -p $DST_DIR
fi

if [ -d $VIM_DST_DIR ]; then
	rm -rf $VIM_DST_DIR
fi

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
./configure --enable-cscope --enable-gui=no --enable-luainterp=yes --enable-multibyte --enable-python3interp --enable-rubyinterp=yes --enable-tclinterp=yes --prefix=$VIM_DST_DIR --with-features=huge --with-tlib=ncurses --without-x

make && make install
