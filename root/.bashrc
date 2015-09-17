# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022
umask 027

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias lla='ls $LS_OPTIONS -lA'
alias l='ls $LS_OPTIONS -CF'

alias grep='grep -i --color=auto'

alias aptu100='/root/bin/aptu.sh 100'
alias aptu='/root/bin/aptu.sh'

alias shutdown='killall amarok; sleep 2; shutdown'
alias poweroff='killall amarok; sleep 2; poweroff'

#alias stl='/opt/lampp/lampp start'
#alias stl='/etc/init.d/apache2 start; /etc/init.d/mysql start'

# switch from de keyboard layout to neo2 and back
alias asdf='/root/.neo2_layout/activate_numlock.sh; cd ~/.neo2_layout; loadkeys neo; cd ~'
alias uiae='loadkeys de'

# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias vimr='vim -R'
alias vim='vim -p'
alias du1='du -h --max-depth=1'

if [ -d ~/bin ] ; then
	PATH=~/bin:"${PATH}"
fi

cd ~
/root/bin/r-check-iptables.sh
