#!/usr/
iptables -t mangle -A INPUT -i eth0 -p tcp --dport 22 -j CONNMARK --set-mark 0x2
iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark
ip rule add fwmark 0x2/0x2 lookup main