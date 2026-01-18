#!/bin/bash

printf "%-6s %-25s %-10s %s\n" "PROTO" "LOCAL ADDR" "PORT" "PROCESS"
echo "---------------------------------------------------------------"

ss -tulnpe 2>/dev/null | tail -n +2 | while read -r line; do
    [[ -z "$line" ]] && continue

    if [[ "$line" == tcp* ]]; then
        proto="TCP"
    elif [[ "$line" == udp* ]]; then
        proto="UDP"
    else
        continue
    fi

    set -- $line
    local_full="$5"

    # Estrai indirizzo e porta
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

    process="unknown"
    pid=""

    # Estrai PID se presente
    if [[ "$line" =~ pid=([0-9]+) ]]; then
        pid="${BASH_REMATCH[1]}"
        if [[ -r "/proc/$pid/exe" ]]; then
            # Prova a leggere il nome reale
            real_exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null)
            if [[ -n "$real_exe" ]]; then
                process="$(basename "$real_exe")"
            else
                # Fallback: prova /proc/PID/comm
                process=$(< "/proc/$pid/comm" 2>/dev/null) || process="unknown"
            fi
        else
            # Senza permessi: usa il nome troncato da ss
            if [[ "$line" =~ users:\(\(\"([^\"]+)\" ]]; then
                process="${BASH_REMATCH[1]}"
            fi
        fi
    else
        # Nessun PID visibile (nessun permesso): usa il nome troncato
        if [[ "$line" =~ users:\(\(\"([^\"]+)\" ]]; then
            process="${BASH_REMATCH[1]}"
        fi
    fi

    printf "%-6s %-25s %-10s %s\n" "$proto" "$addr" "$port_part" "$process"
done
