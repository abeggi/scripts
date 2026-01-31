#!/bin/bash

# Configurazione
DOCKGE_DIR="/dockge"

# Colori per i messaggi
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Errore: Docker non è installato.${NC}"
        exit 1
    fi
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}Errore: Docker Compose (plugin) non è installato.${NC}"
        exit 1
    fi
}

install_dockge() {
    echo -e "${GREEN}Inizio installazione di Dockge in $DOCKGE_DIR...${NC}"

    sudo mkdir -p "$DOCKGE_DIR/stacks"
    sudo chown -R $USER:$USER "$DOCKGE_DIR"
    cd "$DOCKGE_DIR"

    curl https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output docker-compose.yaml

    docker compose up -d

    echo -e "${GREEN}Dockge installato con successo!${NC}"
    echo -e "Porta di default: 5001"
}

uninstall_dockge() {
    echo -e "${RED}Rimozione completa di Dockge (container, volumi e immagini)...${NC}"
    
    if [ -d "$DOCKGE_DIR" ]; then
        cd "$DOCKGE_DIR"
        
        # --volumes: rimuove i volumi nominati definiti nel compose
        # --rmi all: rimuove tutte le immagini utilizzate dai servizi
        docker compose down --volumes --rmi all
        
        cd ..
        sudo rm -rf "$DOCKGE_DIR"
        echo -e "${GREEN}Tutto rimosso con successo.${NC}"
    else
        echo -e "${RED}Directory $DOCKGE_DIR non trovata.${NC}"
    fi
}

check_requirements

case "$1" in
    install)
        install_dockge
        ;;
    uninstall)
        read -p "ATTENZIONE: Questo cancellerà Dockge, i suoi volumi e le immagini. Confermi? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            uninstall_dockge
        fi
        ;;
    *)
        echo "Utilizzo: $0 {install|uninstall}"
        exit 1
        ;;
esac
