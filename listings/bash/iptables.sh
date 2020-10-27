#!/bin/sh
set -x
# My system IP/set ip address of server
# Flushing all rules
iptables -F
iptables -X
# Setting default filter policy
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
# Allow unlimited traffic on loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow incoming ssh only
  iptables -A INPUT -p tcp --sport 513:65535 --dport 22 -j ACCEPT
  iptables -A INPUT -p tcp --sport 80 --dport 22:65535 -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 22 --dport 513:65535 -j ACCEPT
  iptables -A INPUT -p tcp --sport 513:65535 --dport 513:65535 -j ACCEPT
  iptables -A INPUT -p udp --dport 10:65535 -j ACCEPT

for tcpprt in 80 999 8088 3306 9292 9696 35357 5000 10050 10051 8780 5672 6789 8600 8300 8301 8500 11211 623 53 8082 9997 8089 5647 389; do
  iptables -A OUTPUT -p tcp --sport 22:65535 --dport $tcpprt -j ACCEPT
done
  iptables -A INPUT -p tcp --dport 5900:6099 -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 5900:6099 -j ACCEPT
  iptables -A INPUT -p tcp --dport 6800:7300 -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 6800:7300 -j ACCEPT

for udpprt in 8300 8301 623 53 123 67 68; do
  iptables -A OUTPUT -p udp --sport 10:65535 --dport $tcpprt -j ACCEPT
done
# make sure nothing comes or goes out of this box
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
