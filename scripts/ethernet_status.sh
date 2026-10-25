#!/bin/sh
# IPv4 of the first physical interface, ignoring VPN and virtual ones
ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '$2 !~ /^(tun|tap|wg|docker|br-|veth|virbr)/ { split($4, a, "/"); print a[1]; exit }')
echo "${ip:-Offline}"
