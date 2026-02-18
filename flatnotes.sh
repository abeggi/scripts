#!/bin/bash

# Verifica se lo script è eseguito come root (necessario per scrivere in /)
if [ "$EUID" -ne 0 ]; then 
  echo "Errore: Eseguire questo script con sudo (sudo ./setup_flatnotes.sh)"
  exit 1
fi

# 1. Creazione cartella
echo "Creazione cartella /flatnotes..."
mkdir -p /flatnotes

# 2. Creazione file compose.yaml
echo "Creazione file /flatnotes/compose.yaml..."
cat > /flatnotes/compose.yaml << 'EOF'
services:
  flatnotes:
    container_name: flatnotes
    image: dullage/flatnotes:latest
    environment:
      PUID: 1000
      PGID: 1000
      FLATNOTES_AUTH_TYPE: "none"
    volumes:
      - "./data:/data"
    ports:
      - "9000:8080"
    restart: unless-stopped
EOF

# 3. Entrare nella cartella ed eseguire docker compose
echo "Avvio di Docker Compose..."
cd /flatnotes
docker compose up -d

echo "Fatto. Flatnotes dovrebbe essere accessibile su http://localhost:9000"
