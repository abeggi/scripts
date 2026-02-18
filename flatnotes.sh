#!/bin/bash

# esegui con wget https://github.com/abeggi/scripts/raw/refs/heads/main/flatnotes.sh -O - | bash

# Verifica se lo script è eseguito come root
if [ "$EUID" -ne 0 ]; then 
  echo "Errore: Eseguire questo script con sudo (sudo ./setup_flatnotes.sh)"
  exit 1
fi

# 1. Rilevamento indirizzo IP dell'host
HOST_IP=$(hostname -I | awk '{print $1}')

# 2. Scansione porte per trovare quella libera
PORT=9000
echo "Verifica disponibilità porta $PORT..."

# Controlla se la porta è in ascolto usando ss
# Il loop continua finché trova una porta occupata
while ss -tuln | grep -qE ":${PORT}\s"; do
    echo "Porta $PORT già in uso, provo la $((PORT + 1))..."
    PORT=$((PORT + 1))
done

echo "Porta libera trovata: $PORT"

# 3. Creazione cartella
echo "Creazione cartella /flatnotes..."
mkdir -p /flatnotes

# 4. Creazione file compose.yaml
# Nota: Uso EOF senza apici per permettere l'espansione della variabile $PORT
echo "Creazione file /flatnotes/compose.yaml..."
cat > /flatnotes/compose.yaml << EOF
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
      - "$PORT:8080"
    restart: unless-stopped
EOF

# 5. Entrare nella cartella ed eseguire docker compose
echo "Avvio di Docker Compose..."
cd /flatnotes
docker compose up -d

echo "------------------------------------------------"
echo "Fatto. Flatnotes è stato avviato."
echo "Indirizzo IP rilevato: $HOST_IP"
echo "Porta selezionata: $PORT"
echo "Accessibile su: http://$HOST_IP:$PORT"
echo "------------------------------------------------"
