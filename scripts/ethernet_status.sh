#!/bin/sh
# IP of the interface that holds the default route (eth0, wlan0, ens33...)
ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "src") { print $(i + 1); exit }}')
echo "${ip:-Offline}"
