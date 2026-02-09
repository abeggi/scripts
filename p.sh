#!/bin/bash
set -euo pipefail

# Definition of colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Header adapted for new columns
printf "${BOLD}${BLUE}%-6s %-25s %-25s %s${NC}\n" "PROTO" "LOCAL ADDR" "PORT (SERVICE)" "PROCESS"
echo "----------------------------------------------------------------------------------"

# Use process substitution instead of pipe for better performance and variable scope
# Added -a flag to show all connections (not just established)
# Exclude loopback interfaces (127.0.0.1 and ::1) for cleaner output
while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    # Determine Protocol and color
    if [[ "$line" == tcp* ]]; then
        proto="TCP"
        c_proto="$GREEN"
    elif [[ "$line" == udp* ]]; then
        proto="UDP"
        c_proto="$CYAN"
    else
        continue
    fi

    # More robust field extraction using array instead of set --
    read -ra fields <<< "$line"
    local_full="${fields[4]:-}"
    
    [[ -z "$local_full" ]] && continue

    # Extract address and port with better IPv6/IPv4 handling
    if [[ "$local_full" == \[*\]* ]]; then
        # IPv6 format
        addr="${local_full%:*}"
        addr="${addr#[}"
        addr="${addr%]}"
        port_part="${local_full##*:}"
    else
        # IPv4 or IPv6 without brackets
        if [[ "$local_full" == *:* ]]; then
            # Find last colon for port (handles IPv6)
            addr="${local_full%:*}"
            port_part="${local_full##*:}"
        else
            addr="$local_full"
            port_part=""
        fi
    fi

    # Skip loopback addresses for cleaner output
    if [[ "$addr" == "127.0.0.1" || "$addr" == "::1" || "$addr" == "localhost" ]]; then
        continue
    fi

    # Service name resolution
    service=""
    if [[ -n "$port_part" && "$port_part" =~ ^[0-9]+$ ]]; then
        proto_lower="${proto,,}"
        
        # Try /etc/services first (awk for precision)
        if [[ -f /etc/services ]]; then
            service=$(awk -v p="$port_part" -v pr="$proto_lower" '$2 == p"/"pr { print $1; exit }' /etc/services 2>/dev/null) || service=""
        fi
        
        # Fallback to getent if awk didn't find it
        if [[ -z "$service" ]] && command -v getent &>/dev/null; then
            service=$(getent services "$port_part/$proto_lower" 2>/dev/null | awk '{print $1}') || service=""
        fi
    fi

    # Format Port column
    port_display="$port_part"
    if [[ -n "$service" ]]; then
        port_display="$port_part ($service)"
    fi

    process="unknown"
    pid=""

    # Extract PID and Process Name with safer regex
    if [[ "$line" =~ pid=([0-9]+) ]]; then
        pid="${BASH_REMATCH[1]}"
        if [[ -r "/proc/$pid/exe" ]]; then
            real_exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null) || real_exe=""
            if [[ -n "$real_exe" ]]; then
                process="$(basename "$real_exe")"
            else
                process=$(<"/proc/$pid/comm" 2>/dev/null) || process="unknown"
            fi
        else
            # No read permission on /proc/pid/exe - try to extract from ss output
            if [[ "$line" =~ users:\(\(\"([^\"]+)\" ]]; then
                process="${BASH_REMATCH[1]}"
            fi
        fi
    else
        # No visible PID - try to extract from ss output
        if [[ "$line" =~ users:\(\(\"([^\"]+)\" ]]; then
            process="${BASH_REMATCH[1]}"
        fi
    fi

    # Print row with colors
    printf "${c_proto}%-6s${NC} %-25s ${YELLOW}%-25s${NC} %s\n" "$proto" "$addr" "$port_display" "$process"
done < <(ss -tulnpa 2>/dev/null | tail -n +2)
