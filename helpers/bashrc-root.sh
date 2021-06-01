#!/bin/bash

# Use this script on systems with multiple persons working as root
# simply source this snippet after logging in as root to
# have proper prompt and vim look-and-feel

# you will have to copy the .vim directory to /root

# source /home/xee8ai/bashrc-root.sh

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
USERNAME=$(echo "/home/par/dotfiles/helpers" | cut -d'/' -f3)

FILEPATH="/home/$USERNAME/.mybash/liquidprompt/liquidprompt"
if [ -e $FILEPATH ]; then
	source $FILEPATH
else
	echo "Ignoring non-existing $FILEPATH…"
fi

FILEPATH="/home/$USERNAME/dotfiles/.bashrc__general__aliases_exports"
if [ -e $FILEPATH ]; then
	source $FILEPATH
else
	echo "Ignoring non-existing $FILEPATH…"
fi

if [ -e /home/$USERNAME/src/vim/src/vim ]; then
        VIM='/home/$USERNAME/src/vim/src/vim'
else
        VIM='/usr/bin/env vim'
fi

alias vimr="$VIM -u /home/$USERNAME/dotfiles/.vimrc --cmd 'set rtp^=/home/$USERNAME/.vim' -R -p"
alias vim="$VIM -u /home/$USERNAME/dotfiles/.vimrc --cmd 'set rtp^=/home/$USERNAME/.vim' -p"
alias vimdiff="$VIM -u /home/$USERNAME/dotfiles/.vimrc --cmd 'set rtp^=/home/$USERNAME/.vim' -d"
