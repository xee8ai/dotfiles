# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# colorize „root“ in prompt
# https://wiki.archlinux.de/title/Bash-Prompt_anpassen
PS1='${debian_chroot:+($debian_chroot)}\[\033[0;31m\]\u\[\033[0m\]@\h:\w# '
# umask 022
umask 027

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias lla='ls $LS_OPTIONS -lA'
alias la='ls $LS_OPTIONS -A'
alias l='ls $LS_OPTIONS -CF'

alias grep='grep --color=auto'
alias ggrep='grep -inTs --color=auto'
alias igrep='grep -is --color=auto'
alias sgrep='grep -s --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep -s --color=auto'

alias aptu100='/root/bin/aptu.sh 100'
alias aptu='/root/bin/aptu.sh'

alias shutdown='killall amarok; sleep 2; shutdown'
alias poweroff='killall amarok; sleep 2; poweroff'

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
