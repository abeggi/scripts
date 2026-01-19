#!/bin/bash
set -e

# Configurazione non interattiva per apt
export DEBIAN_FRONTEND=noninteractive

# Colori
WHITE='\033[1;37m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Funzione log
log() { echo -e "${GREEN}[*] $1${NC}"; }
info() { echo -e "${CYAN}    $1${NC}"; }
warn() { echo -e "${YELLOW}    $1${NC}"; }

# Variabili
REPO_URL="https://github.com/abeggi/scripts/raw/main"
HOME_DIR="/root"

# 1. Configurazione Bash: Colori e Aliases
log "Configuring bash environment..."
mkdir -p "$HOME_DIR"
if [ -f "$HOME_DIR/.bashrc" ]; then
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' "$HOME_DIR/.bashrc"
else
    echo "force_color_prompt=yes" > "$HOME_DIR/.bashrc"
fi

info "Downloading .bash_aliases..."
wget -q "$REPO_URL/.bash_aliases" -O "$HOME_DIR/.bash_aliases" || warn "Warning: Failed to download .bash_aliases"

# 2. Aggiornamento e Installazione pacchetti (Muted)
log "Updating system and installing packages..."
info "apt update..."
apt-get update -qq >/dev/null

info "apt install utilities..."
apt-get install -qq -y curl wget mc htop ncdu tldr duf bat >/dev/null

info "apt upgrade..."
apt-get upgrade -qq -y >/dev/null

info "apt dist-upgrade..."
apt-get dist-upgrade -qq -y >/dev/null

info "apt purge apparmor..."
apt-get purge -qq -y apparmor apparmor-utils >/dev/null 2>&1 || true

info "apt cleaning..."
apt-get autoremove --purge -qq -y >/dev/null
apt-get clean >/dev/null && rm -rf /var/lib/apt/lists/*

# 3. Setup Timezone
log "Setting timezone to Europe/Rome..."
ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime
dpkg-reconfigure -f noninteractive tzdata >/dev/null 2>&1

# 4. Download Scripts Utente
log "Downloading custom scripts..."
cd "$HOME_DIR"

download_script() {
    info "Getting $1..."
    wget -q "$REPO_URL/$1" -O "$1" && chmod +x "$1"
}

download_script "aggiorna.sh"
download_script "sysinfo.sh"
download_script "fileman.sh"

info "Getting n (node manager)..."
wget -q "$REPO_URL/n.sh" -O /usr/local/bin/n && chmod +x /usr/local/bin/n

# Filebrowser
log "Installing Filebrowser..."
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash >/dev/null 2>&1

# 5. Configurazione Sysinfo all'avvio
log "Configuring sysinfo startup..."
if ! grep -Fxq "$HOME_DIR/sysinfo.sh" "$HOME_DIR/.bashrc"; then
    echo "$HOME_DIR/sysinfo.sh" >> "$HOME_DIR/.bashrc"
    info "Added sysinfo.sh to .bashrc"
fi

# 6. Configurazione SSH
log "Configuring SSH..."
if [ -f /etc/ssh/sshd_config ]; then
    info "Enabling Root Login..."
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    # Assicura anche PasswordAuthentication (spesso richiesto insieme)
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    
    info "Restarting SSH service..."
    service ssh restart >/dev/null 2>&1 || systemctl restart ssh >/dev/null 2>&1 || /etc/init.d/ssh restart >/dev/null 2>&1 || warn "Could not restart SSH service"
else
    warn "SSH config file not found, skipping SSH setup."
fi

log "Setup completato."

IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}[*] SSH Connection: ${WHITE}ssh root@$IP${NC}"
