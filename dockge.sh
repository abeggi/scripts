#!/bin/bash

# Configurazione
DOCKGE_DIR="/dockge"

# Colori
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Funzione Aiuto
show_help() {
    echo -e "${GREEN}Gestore Installazione Dockge${NC}"
    echo -e "Utilizzo: $0 {install|uninstall}"
    echo "-----------------------------------"
    echo "install   : Crea /dockge, scarica il compose e avvia il servizio"
    echo "uninstall : Rimuove container, immagini, volumi e la directory /dockge"
    echo ""
}

check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Errore: Docker non è installato.${NC}"
        exit 1
    fi
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}Errore: Docker Compose non è installato.${NC}"
        exit 1
    fi
}

install_dockge() {
    echo -e "${GREEN}Inizio installazione...${NC}"
    sudo mkdir -p "$DOCKGE_DIR/stacks"
    sudo chown -R $USER:$USER "$DOCKGE_DIR"
    cd "$DOCKGE_DIR"
    curl -sSL https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output docker-compose.yaml
    docker compose up -d
    echo -e "${GREEN}Dockge pronto su porta 5001!${NC}"
}

uninstall_dockge() {
    echo -e "${RED}Rimozione totale in corso...${NC}"
    if [ -d "$DOCKGE_DIR" ]; then
        cd "$DOCKGE_DIR"
        docker compose down --volumes --rmi all
        cd ..
        sudo rm -rf "$DOCKGE_DIR"
        echo -e "${GREEN}Pulizia completata.${NC}"
    else
        echo -e "${RED}Cartella $DOCKGE_DIR non trovata.${NC}"
    fi
}

# Controllo se l'argomento è vuoto
if [ -z "$1" ]; then
    show_help
    exit 0
fi

check_requirements

case "$1" in
    install)
        install_dockge
        ;;
    uninstall)
        # Il flag < /dev/tty permette l'input interattivo via pipe (curl | bash)
        read -p "Confermi la cancellazione totale? (y/n) " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            uninstall_dockge
        fi
        ;;
    *)
        show_help
        exit 1
        ;;
esac
