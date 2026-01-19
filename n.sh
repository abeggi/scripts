#!/bin/bash

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

ss -tulnpe 2>/dev/null | tail -n +2 | while read -r line; do
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

    set -- $line
    local_full="$5"

    # Extract address and port
    if [[ "$local_full" == \[*\]* ]]; then
        addr="${local_full%:*}"
        addr="${addr#[}"
        addr="${addr%]}"
        port_part="${local_full##*:}"
    else
        if [[ "$local_full" == *:* ]]; then
            addr="${local_full%:*}"
            port_part="${local_full##*:}"
        else
            addr="$local_full"
            port_part=""
        fi
    fi

    # Service name resolution
    service=""
    if [[ -n "$port_part" ]]; then
        # Try /etc/services first (awk for precision)
        proto_lower="${proto,,}" 
        if [[ -f /etc/services ]]; then
            service=$(awk -v p="$port_part" -v pr="$proto_lower" '$2 == p"/"pr { print $1; exit }' /etc/services 2>/dev/null)
        fi
        
        # Fallback to getent if awk didn't find it or file missing
        if [[ -z "$service" ]] && command -v getent >/dev/null 2>&1; then
             service=$(getent services "$port_part/$proto_lower" 2>/dev/null | awk '{print $1}')
        fi
    fi

    # Format Port column
    port_display="$port_part"
    if [[ -n "$service" ]]; then
        port_display="$port_display ($service)"
    fi

    process="unknown"
    pid=""

    # Extract PID and Process Name
    if [[ "$line" =~ pid=([0-9]+) ]]; then
        pid="${BASH_REMATCH[1]}"
        if [[ -r "/proc/$pid/exe" ]]; then
            real_exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null)
            if [[ -n "$real_exe" ]]; then
                process="$(basename "$real_exe")"
            else
                process=$(< "/proc/$pid/comm" 2>/dev/null) || process="unknown"
            fi
        else
             # No read permission on /proc/pid/exe
            if [[ "$line" =~ users:\(\(\"([^\"]+)\" ]]; then
                process="${BASH_REMATCH[1]}"
            fi
        fi
    else
        # No visible PID
        if [[ "$line" =~ users:\(\(\"([^\"]+)\" ]]; then
            process="${BASH_REMATCH[1]}"
        fi
    fi

    # Print row with colors
    printf "${c_proto}%-6s${NC} %-25s ${YELLOW}%-25s${NC} %s\n" "$proto" "$addr" "$port_display" "$process"
done

