#! /bin/bash
cd
sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /root/.bashrc
apt update
apt install curl wget mc htop ncdu tldr duf bat -y
apt purge apparmor apparmor-utils -y
wget https://github.com/abeggi/scripts/raw/main/.bash_aliases -O .bash_aliases
wget https://github.com/abeggi/scripts/raw/main/aggiorna.sh -O aggiorna.sh
chmod +x aggiorna.sh
wget https://github.com/abeggi/scripts/raw/main/sysinfo.sh -O sysinfo.sh
chmod +x sysinfo.sh
wget https://github.com/abeggi/scripts/raw/main/n.sh -O /usr/local/bin/n
chmod +x /usr/local/bin/n.sh
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
wget https://github.com/abeggi/scripts/raw/main/fileman.sh -O fileman.sh
chmod +x fileman.sh
timedatectl set-timezone Europe/Rome
source .bashrc
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
source .bashrc
