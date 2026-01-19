#!/bin/bash
set -e

# Configurazione non interattiva per apt
export DEBIAN_FRONTEND=noninteractive

# Variabili
REPO_URL="https://github.com/abeggi/scripts/raw/main"
HOME_DIR="/root"

# 1. Configurazione Bash: Colori e Aliases
echo "Configuring bash environment..."
# Assicura che la directory esista (per container minimali)
mkdir -p "$HOME_DIR"
if [ -f "$HOME_DIR/.bashrc" ]; then
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' "$HOME_DIR/.bashrc"
else
    # Crea un .bashrc minimale se non esiste
    echo "force_color_prompt=yes" > "$HOME_DIR/.bashrc"
fi

# Scarica .bash_aliases
wget -q "$REPO_URL/.bash_aliases" -O "$HOME_DIR/.bash_aliases" || echo "Warning: Failed to download .bash_aliases"

# 2. Aggiornamento e Installazione pacchetti
echo "Updating system and installing packages..."
apt-get update
apt-get install -y curl wget mc htop ncdu tldr duf bat
apt-get purge -y apparmor apparmor-utils || true # Ignora errore se non installati
apt-get autoremove --purge -y
apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Setup Timezone
echo "Setting timezone to Europe/Rome..."
ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# 4. Download Scripts Utente
echo "Downloading custom scripts..."
cd "$HOME_DIR"

# helper function per scaricare e rendere eseguibile
download_script() {
    wget -q "$REPO_URL/$1" -O "$1" && chmod +x "$1"
}

download_script "aggiorna.sh"
download_script "sysinfo.sh"
download_script "fileman.sh"

# n.sh (Node manager) - Percorso specifico
wget -q "$REPO_URL/n.sh" -O /usr/local/bin/n && chmod +x /usr/local/bin/n

# Filebrowser
echo "Installing Filebrowser..."
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# 5. Configurazione Sysinfo all'avvio
echo "Configuring sysinfo startup..."
if ! grep -Fxq "$HOME_DIR/sysinfo.sh" "$HOME_DIR/.bashrc"; then
    echo "$HOME_DIR/sysinfo.sh" >> "$HOME_DIR/.bashrc"
fi

echo "Setup completato."
