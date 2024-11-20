#! /bin/bash
ip_addr=$(ip -4 addr show dev wlan0 | grep inet | awk '{print $2}' | cut -d/ -f1)
echo "**********************************"
echo "Vai a: http://$ip_addr:8080"
echo "**********************************"
filebrowser -a 0.0.0.0 --noauth -r /
