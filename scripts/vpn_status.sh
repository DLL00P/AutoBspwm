#!/bin/sh
# First tun* interface with an IPv4 address (HTB / THM / OpenVPN)
ip=$(ip -4 -o addr show 2>/dev/null | awk '$2 ~ /^(tun|tap|wg)/ { split($4, a, "/"); print a[1]; exit }')
echo "${ip:-Disconnected}"
