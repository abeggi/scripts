#!/bin/bash
hostname=$(hostname)
ip_address=$(ip -4 addr show dev wlan0 | grep inet | awk '{print $2}' | cut -d/ -f1)
curl -d "Hostname: $hostname, Indirizzo WLAN0: $ip_address" ntfy.sh/beggi-pi
