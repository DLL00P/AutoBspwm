#!/bin/sh
# IP of the interface that holds the default route (eth0, wlan0, ens33...)
ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '$2 !~ /^(tun|tap|wg|docker|br-|veth|virbr)/ { split($4, a, "/"); print a[1]; exit }')
echo "${ip:-Offline}"
