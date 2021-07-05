#!/bin/bash

# script to setup iptables rules
# we do not use /sbin/iptables-restore anymore:
# if one of the hostnames cannot be resolved the complete ruleset will not be applied
# resulting in an completely open setting after a restart!

IPTABLES="/sbin/iptables"


################################################################################
# clear rules
$IPTABLES -F
$IPTABLES -X


################################################################################
# set policies to DROP
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP


################################################################################
# add chains
$IPTABLES -N XEE_INPUT_SSH
$IPTABLES -N FWKNOP_INPUT


################################################################################
# rules
$IPTABLES -A INPUT -m state --state INVALID -j DROP
$IPTABLES -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
$IPTABLES -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
$IPTABLES -A INPUT -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
$IPTABLES -A INPUT -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
$IPTABLES -A INPUT -p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP
$IPTABLES -A INPUT -p tcp -m tcp --tcp-flags PSH,ACK PSH -j DROP
$IPTABLES -A INPUT -p tcp -m tcp --tcp-flags ACK,URG URG -j DROP
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p icmp -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type 8 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -j XEE__INPUT_SSH

$IPTABLES -A OUTPUT -m state --state INVALID -j DROP
$IPTABLES -A OUTPUT -o lo -j ACCEPT
$IPTABLES -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -p icmp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

$IPTABLES -A XEE__INPUT_SSH -s 127.0.0.1/32 -j ACCEPT
