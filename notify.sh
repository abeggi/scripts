#!/bin/bash
hostname=$(hostname)
ip_address=$(ip -4 addr show dev wlan0 | grep inet | awk '{print $2}' | cut -d/ -f1)
curl -H "Tags: green_circle" -H "Title: $hostname: " -d "$ip_address" ntfy.sh/beggi-pi
