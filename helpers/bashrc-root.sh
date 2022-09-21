#!/bin/bash

# Use this script on systems with multiple persons working as root
# simply source this snippet after logging in as root to
# have proper prompt and vim look-and-feel

# you will have to copy the .vim directory to /root

# source /home/xee8ai/bashrc-root.sh

# we have to extract the username from scriptdir (because $USER and whoami are “root”)
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
USERNAME=$(echo "$SCRIPT_DIR" | cut -d'/' -f3)

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

LOCALVIMPATH="/home/$USERNAME/.local/vim/bin/vim"
if [ -e $LOCALVIMPATH ]; then
        VIM=$LOCALVIMPATH
else
        VIM="/usr/bin/env vim"
fi

alias vimr="$VIM -u /home/$USERNAME/dotfiles/.vimrc --cmd 'set rtp^=/home/$USERNAME/.vim' -R -p"
alias vim="$VIM -u /home/$USERNAME/dotfiles/.vimrc --cmd 'set rtp^=/home/$USERNAME/.vim' -p"
alias vimdiff="$VIM -u /home/$USERNAME/dotfiles/.vimrc --cmd 'set rtp^=/home/$USERNAME/.vim' -d"

# check if we want to symlink to users .gitconfig, too
# this is done if “/root/.gitconfig-root” exists
GITCONFIG_ROOT="/root/.gitconfig"
GITCONFIG_ROOT_BACKUP="/root/.gitconfig-root"
GITCONFIG_USER="/home/$USERNAME/.gitconfig"
if [ -e $GITCONFIG_ROOT_BACKUP ]; then
    echo "Symlinking $GITCONFIG_ROOT to $GITCONFIG_USER"
    unlink $GITCONFIG_ROOT
    ln -s $GITCONFIG_USER $GITCONFIG_ROOT
fi

# check if git user exists and add alias
GIT_USER="/home/$USERNAME/dotfiles/helpers/git-user.py"
alias gu='echo "~/dotfiles/helpers/git-user.py does not exist"'
if [ -f $GIT_USER ]; then
    PYTHON3_VERSION=$(/usr/bin/env python3 --version)
    if [ $? -eq 0 ]; then
        alias gu=$GIT_USER
    fi
fi
