#!/bin/bash

# Configurazione
DOCKGE_DIR="/dockge"
PORT="5001"

# Colori
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}Gestore Installazione Dockge${NC}"
    echo -e "Utilizzo: $0 {install|uninstall}"
    echo "-----------------------------------"
    echo "install   : Configura Dockge in /dockge"
    echo "uninstall : Rimuove tutto (dati, volumi e immagini)"
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

get_ip() {
    # Tenta di recuperare l'IP locale principale
    hostname -I | awk '{print $1}'
}

install_dockge() {
    echo -e "${BLUE}Inizio installazione...${NC}"
    
    sudo mkdir -p "$DOCKGE_DIR/stacks"
    sudo chown -R $USER:$USER "$DOCKGE_DIR"
    cd "$DOCKGE_DIR" || exit
    
    curl -sSL https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output docker-compose.yaml
    
    echo -e "${BLUE}Avvio dei container...${NC}"
    docker compose up -d
    
    IP_ADDR=$(get_ip)
    
    echo -e "\n${GREEN}==============================================${NC}"
    echo -e "${GREEN}   DOCKGE INSTALLATO CON SUCCESSO!${NC}"
    echo -e "${GREEN}==============================================${NC}"
    echo -e "Puoi aggiungerlo alla tua homepage ${BLUE}Heimdall${NC} usando:"
    echo -e "${BLUE}http://${IP_ADDR}:${PORT}${NC}"
    echo -e "${GREEN}==============================================${NC}\n"
}

uninstall_dockge() {
    echo -e "${RED}Rimozione totale in corso...${NC}"
    if [ -d "$DOCKGE_DIR" ]; then
        cd "$DOCKGE_DIR" || exit
        docker compose down --volumes --rmi all
        cd ..
        sudo rm -rf "$DOCKGE_DIR"
        echo -e "${GREEN}Pulizia completata. Sistema pulito.${NC}"
    else
        echo -e "${RED}Cartella $DOCKGE_DIR non trovata.${NC}"
    fi
}

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
