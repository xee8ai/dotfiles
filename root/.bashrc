# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# colorize „root“ in prompt
# https://wiki.archlinux.de/title/Bash-Prompt_anpassen
# https://unix.stackexchange.com/questions/31695/how-to-make-the-terminal-display-usermachine-in-bold-letters
# 0;31m is normal red, 1;31m is boldface red
PS1='${debian_chroot:+($debian_chroot)}\[\033[1;31m\]\u\[\033[0m\]@\h:\w# '
# umask 022
umask 027

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
# some more ls aliases
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lF'
alias lla='ls $LS_OPTIONS -AlF'
alias la='ls $LS_OPTIONS -A'
alias l='ls $LS_OPTIONS -CF'

alias grep='grep --color=auto'
alias ggrep='grep -inTs --color=auto'
alias igrep='grep -is --color=auto'
alias sgrep='grep -s --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep -s --color=auto'
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias du1='du -h --max-depth=1'

# Umschalter DE-Layout=>NEO2 und zurück (virtuelle Konsolen)
# benötigt von Patrick (der sonst nicht richtig tippen kann ;-) )
alias asdf='/root/.neo2_layout/activate_numlock.sh; cd ~/.neo2_layout; loadkeys neo; cd ~'
alias uiae='loadkeys de'

# und zum bequemeren Upgraden
# von par, der sich an der Stelle gern Tipparbeit spart
alias aptu="/root/bin/aptu.sh"

# vim readonly öffnen:
alias vimr='vim -R'

# open multiple files in tabs
alias vim='vim -p'

# close amarok before shutdown
alias shutdown='rm -f /etc/hosts; cp -fa /etc/hosts.original /etc/hosts; killall amarok; sleep 2; shutdown'
alias poweroff='rm -f /etc/hosts; cp -fa /etc/hosts.original /etc/hosts; killall amarok; sleep 2; poweroff'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi

# par: /root/bin in PATH aufnehmen
if test -e /root/bin; then PATH="/root/bin:"$PATH; fi

# in /root wechseln
cd /root
/root/bin/check_iptables.sh
