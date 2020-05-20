#!/bin/bash

# Use this script on systems with multiple persons working as root
# simply source this snippet after logging in as root to
# have proper prompt and vim look-and-feel

# you will have to copy the .vim directory to /root

# source /home/xee8ai/bashrc-root.sh

USERNAME='xee8ai'

source /home/$USERNAME/.mybash/liquidprompt/liquidprompt

source /home/$USERNAME/dotfiles/.bashrc__general__aliases_exports

alias vimr="vim -u /home/$USERNAME/dotfiles/.vimrc -R -p"
alias vim="vim -u /home/$USERNAME/dotfiles/.vimrc -p"
