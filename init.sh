#! /bin/bash
#
cd
sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /root/.bashrc
apt update
apt install curl wget mc htop ncdu tldr -y
wget https://github.com/abeggi/scripts/raw/main/.bash_aliases
wget https://github.com/abeggi/scripts/raw/main/aggiorna.sh
chmod +x aggiorna.sh
wget https://github.com/abeggi/scripts/raw/main/sysinfo.sh
chmod +x sysinfo.sh
timedatectl set-timezone Europe/Rome
# File .bashrc dell'utente root
BASHRC="/root/.bashrc"
# Riga da aggiungere
LINE_TO_ADD="/root/sysinfo.sh"
# Controlla se la riga è già presente
if grep -Fxq "$LINE_TO_ADD" "$BASHRC"; then
    echo "La riga '$LINE_TO_ADD' è già presente in $BASHRC."
else
    # Aggiunge la riga alla fine del file
    echo "$LINE_TO_ADD" >> "$BASHRC"
    echo "La riga '$LINE_TO_ADD' è stata aggiunta a $BASHRC."
fi
