#! /bin/bash
#
apt update
apt install mc htop ncdu -y
wget https://github.com/abeggi/scripts/raw/main/.bash_aliases
wget https://github.com/abeggi/scripts/raw/main/aggiorna.sh
chmod +x aggiorna.sh
timedatectl set-timezone Europe/Rome
