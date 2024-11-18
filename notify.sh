#!/bin/bash
hostname=$(hostname)
ip_address=$(ip -4 addr show dev wlan0 | grep inet | awk '{print $2}' | cut -d/ -f1)
curl -T "Title: $hostname" -d "$ip_address" ntfy.sh/beggi-pi
