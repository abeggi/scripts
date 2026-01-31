#!/bin/bash

# Configurazione
DOCKGE_DIR="/dockge"
STACKS_DIR="$DOCKGE_DIR/stacks"
PORT="5001"

# Colori
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}Gestore Installazione Dockge${NC}"
    echo -e "Utilizzo: $0 {install|uninstall}"
    echo "-----------------------------------"
    echo "install   : Configura Dockge tutto in $DOCKGE_DIR"
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
    hostname -I | awk '{print $1}'
}

install_dockge() {
    echo -e "${BLUE}Inizio installazione...${NC}"
    
    # Creazione directory
    sudo mkdir -p "$STACKS_DIR"
    sudo chown -R $USER:$USER "$DOCKGE_DIR"
    cd "$DOCKGE_DIR" || exit
    
    # Download del compose
    curl -sSL https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output docker-compose.yaml
    
    # CORREZIONE: Modifichiamo il file scaricato per puntare a /dockge/stacks invece di /opt/stacks
    # Usiamo sed per cambiare il mapping del volume
    sed -i "s|/opt/stacks|$STACKS_DIR|g" docker-compose.yaml
    
    echo -e "${BLUE}Avvio dei container con configurazione custom...${NC}"
    docker compose up -d
    
    IP_ADDR=$(get_ip)
    
    echo -e "\n${GREEN}==============================================${NC}"
    echo -e "${GREEN}   DOCKGE INSTALLATO CON SUCCESSO!${NC}"
    echo -e "${GREEN}==============================================${NC}"
    echo -e "Tutti i dati e gli stack sono in: ${YELLOW}$DOCKGE_DIR${NC}"
    echo -e "URL per la tua homepage ${BLUE}Heimdall${NC}:"
    echo -e "${YELLOW}http://${IP_ADDR}:${PORT}${NC}"
    echo -e "${GREEN}==============================================${NC}\n"
}

uninstall_dockge() {
    echo -e "${RED}Rimozione totale in corso...${NC}"
    if [ -d "$DOCKGE_DIR" ]; then
        cd "$DOCKGE_DIR" || exit
        docker compose down --volumes --rmi all
        cd ..
        sudo rm -rf "$DOCKGE_DIR"
        echo -e "${GREEN}Pulizia completata. Cartella $DOCKGE_DIR rimossa.${NC}"
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
        read -p "Confermi la cancellazione totale di Dockge e di TUTTI gli stack in $DOCKGE_DIR? (y/n) " -n 1 -r < /dev/tty
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
