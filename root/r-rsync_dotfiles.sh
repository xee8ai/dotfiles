#!/bin/bash

# Sync dotfiles from user to root

USAGE="$0 user_to_sync_from"

echo

# check if a param (=username) given
if [ "$#" -ne 1 ]; then
	echo "ERROR: No username given"
	echo
	echo $USAGE
	echo
	exit 1
fi

# check if there is a home directory for the given user
if [ ! -d "/home/$1" ]; then
	echo "ERROR: $1 seems not to be a valid user (there is no home dir /home/$1)"
	echo
	echo $USAGE
	echo
	exit 1
fi

# it seems so – apply to a better varname
USERNAME=$1

# define source dirs to sync from
SRC="/home/$USERNAME/.vim
/home/$USERNAME/.mybash
/home/$USERNAME/dotfiles/root/.neo2_layout
/home/$USERNAME/dotfiles/.vimrc"

# destination dir
DST="/root"

RSYNCOPTS="-avrpEL --delete"

# change owner to $USERNAME => see better what is going to be synced
chown -R $USERNAME.$USERNAME /root/.vim
chown -R $USERNAME.$USERNAME /root/.vimrc
chown -R $USERNAME.$USERNAME /root/.mybash
chown -R $USERNAME.$USERNAME /root/.neo2_layout

# sync files
for S in $SRC; do

	# return if source does not exist to prevent data loss
	if [ ! -e $S ]; then
		echo "ERROR: Source path $S does not exist!"
		echo "Exiting…"
		echo
		exit 1
	fi

	rsync $RSYNCOPTS $S $DST
done

# copy the aliases file
cp -f /home/$USERNAME/dotfiles/.bashrc__general__aliases_exports /root/.bash_aliases

# copy the sync file
cp -f /home/$USERNAME/dotfiles/root/r-rsync_dotfiles.sh /root/dotfiles

# copy the helpers
cp -rf /home/$USERNAME/dotfiles/helpers /root/dotfiles

# change owner back to root
chown -R root.root /root

echo
