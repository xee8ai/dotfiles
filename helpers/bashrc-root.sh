#!/bin/bash

# Use this script on systems with multiple persons working as root
# simply source this snippet after logging in as root to
# have proper prompt and vim look-and-feel

# you will have to copy the .vim directory to /root

# source /home/xee8ai/bashrc-root.sh

USERNAME='xee8ai'

source /home/$USERNAME/.mybash/liquidprompt/liquidprompt

source /home/$USERNAME/dotfiles/.bashrc__general__aliases_exports

if [ -e /home/$USERNAME/src/vim/src/vim ]; then
        VIM='/home/$USERNAME/src/vim/src/vim'
else
        VIM='/usr/bin/env vim'
fi

alias vimr="$VIM -u /home/$USERNAME/dotfiles/.vimrc -R -p"
alias vim="$VIM -u /home/$USERNAME/dotfiles/.vimrc -p"
