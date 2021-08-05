#!/bin/bash

# script to setup iptables rules
# we do not use /sbin/iptables-restore anymore:
# if one of the hostnames cannot be resolved the complete ruleset will not be applied
# resulting in an completely open setting after a restart!

IP6TABLES="/sbin/ip6tables -w"


################################################################################
# clear rules
$IP6TABLES -F
$IP6TABLES -X


################################################################################
# set policies to DROP
$IP6TABLES -P INPUT DROP
$IP6TABLES -P OUTPUT DROP
$IP6TABLES -P FORWARD DROP


################################################################################
# add chains
$IP6TABLES -N FWKNOP_INPUT


################################################################################
# rules
$IP6TABLES -A INPUT -m state --state INVALID -j DROP
$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
$IP6TABLES -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
$IP6TABLES -A INPUT -p icmp -m state --state RELATED,ESTABLISHED -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp -m state --state RELATED,ESTABLISHED -j ACCEPT

$IP6TABLES -A OUTPUT -o lo -j ACCEPT
$IP6TABLES -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
$IP6TABLES -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
$IP6TABLES -A OUTPUT -p icmp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IP6TABLES -A OUTPUT -p ipv6-icmp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
