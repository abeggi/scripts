#!/bin/bash

# Ottieni il nome host
hostname=$(hostname)

# Ottieni l'indirizzo IP
ip_address=$(hostname -I | awk "{print \$1}")

# Ottieni lo spazio disco totale e utilizzato
disk_usage_total=$(df -h / | awk "NR==2 {print \$2}")
disk_usage_used=$(df -h / | awk "NR==2 {print \$3}")

# Ottieni la memoria RAM totale e utilizzata
mem_total=$(free -h | awk "NR==2 {print \$2}")
mem_used=$(free -h | awk "NR==2 {print \$3}")

# Ottieni il carico della CPU dai dati di /proc/loadavg
cpu_load=$(awk "{print \$1 \" (1 min), \" \$2 \" (5 min), \" \$3 \" (15 min)\"}" /proc/loadavg)

# Stampa le informazioni con una tabella ben allineata
/usr/bin/clear -x
echo "======================================="
echo "          Informazioni di Sistema      "
echo "======================================="
echo "$info"
printf "%-20s : %s\n" "Hostname" "$hostname"
printf "%-20s : %s\n" "Indirizzo IP" "$ip_address"
printf "%-20s : %s / %s\n" "Disco usato / totale" "$disk_usage_used" "$disk_usage_total"
printf "%-20s : %s / %s\n" "RAM usata / totale" "$mem_used"  "$mem_total"
printf "%-20s : %s / %s\n" "Carico CPU" "$cpu_load"
