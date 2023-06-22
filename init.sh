#! /bin/bash
#
cd
sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /root/.bashrc
apt update
apt install curl wget mc htop ncdu tldr -y
wget https://github.com/abeggi/scripts/raw/main/.bash_aliases
wget https://github.com/abeggi/scripts/raw/main/aggiorna.sh
chmod +x aggiorna.sh
timedatectl set-timezone Europe/Rome
