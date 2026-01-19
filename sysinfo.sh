#!/bin/bash

# Definition of colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Clear screen keeping scrollback
clear -x

# Gather Info
hostname=$(hostname)
ip_address=$(hostname -I | awk '{print $1}')
disk_usage=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
mem_usage=$(free -h | awk 'NR==2 {print $3 " / " $2}')
load=$(awk '{print $1 ", " $2 ", " $3}' /proc/loadavg)
up=$(uptime -p | sed 's/up //')

# OS Name
if [ -f /etc/os-release ]; then
    source /etc/os-release
    os_name="$PRETTY_NAME"
else
    os_name=$(uname -srm)
fi

# Kernel
kernel=$(uname -r)

# Header
echo -e "${BLUE}=======================================${NC}"
echo -e "${WHITE}      Informazioni di Sistema          ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Print Info
printf "${CYAN}%-20s${NC} : ${WHITE}%s${NC}\n" "OS" "$os_name"
printf "${CYAN}%-20s${NC} : ${WHITE}%s${NC}\n" "Kernel" "$kernel"
printf "${CYAN}%-20s${NC} : ${WHITE}%s${NC}\n" "Hostname" "$hostname"
printf "${CYAN}%-20s${NC} : ${GREEN}%s${NC}\n" "IP Address" "$ip_address"
printf "${CYAN}%-20s${NC} : ${YELLOW}%s${NC}\n" "Disk (Used/Tot)" "$disk_usage"
printf "${CYAN}%-20s${NC} : ${YELLOW}%s${NC}\n" "RAM (Used/Tot)" "$mem_usage"
printf "${CYAN}%-20s${NC} : ${WHITE}%s${NC}\n" "CPU Load (1,5,15)" "$load"
printf "${CYAN}%-20s${NC} : ${WHITE}%s${NC}\n" "Uptime" "$up"
echo -e "${BLUE}=======================================${NC}"

