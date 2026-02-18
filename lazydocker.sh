#!/bin/bash

# Verifica se lo script è eseguito come root
if [ "$EUID" -ne 0 ]; then 
  echo "Errore: Eseguire questo script con sudo (sudo ./install_lazydocker.sh)"
  exit 1
fi

echo "========================================"
echo "Installazione di Lazydocker"
echo "========================================"

# 1. Verifica Docker
echo "Verifica installazione Docker..."
if ! command -v docker &> /dev/null; then
    echo "Errore: Docker non è installato."
    exit 1
fi
echo "✓ Docker: $(docker --version)"

# 2. Verifica se già installato
if command -v lazydocker &> /dev/null; then
    echo "✓ Lazydocker già installato: $(lazydocker --version)"
    read -p "Vuoi reinstallare/aggiornare? (y/n): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
fi

# 3. Rileva architettura e mappa ai nomi usati da Lazydocker
echo "Rilevamento architettura..."
ARCH=$(uname -m)
case $ARCH in
    x86_64) 
        ARCH="x86_64"  # Lazydocker usa x86_64, non amd64
        ;;
    aarch64|arm64) 
        ARCH="arm64" 
        ;;
    armv7l) 
        ARCH="armv7" 
        ;;
    armv6l) 
        ARCH="armv6" 
        ;;
    i386|i686) 
        ARCH="x86"  # Per sistemi a 32-bit
        ;;
    *) 
        echo "Errore: Architettura non supportata ($ARCH)"
        exit 1 
        ;;
esac
echo "✓ Architettura rilevata: $ARCH"

# 4. Ottieni ultima versione da GitHub
echo "Ricerca ultima versione..."
LATEST=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$LATEST" ]; then
    echo "Errore: Impossibile recuperare la versione più recente"
    exit 1
fi
echo "✓ Versione: $LATEST"

# 5. Costruisci URL di download con il nome corretto
URL="https://github.com/jesseduffield/lazydocker/releases/download/${LATEST}/lazydocker_${LATEST#v}_Linux_${ARCH}.tar.gz"
echo "Download da: $URL"

# 6. Scarica ed estrai in cartella temporanea
TEMP_DIR=$(mktemp -d)
echo "Download in corso..."
if ! curl -fsSL "$URL" -o "$TEMP_DIR/lazydocker.tar.gz"; then
    echo "✗ Errore nel download (HTTP 404 o problema di rete)"
    echo "  URL provato: $URL"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Estrazione..."
if ! tar -xzf "$TEMP_DIR/lazydocker.tar.gz" -C "$TEMP_DIR"; then
    echo "✗ Errore nell'estrazione dell'archivio"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 7. Installa il binario
echo "Installazione in /usr/local/bin..."
# Cerca il binario (potrebbe essere in una sottocartella)
BIN_PATH=$(find "$TEMP_DIR" -name "lazydocker" -type f -executable | head -n1)
if [ -n "$BIN_PATH" ] && [ -f "$BIN_PATH" ]; then
    mv "$BIN_PATH" /usr/local/bin/
    chmod +x /usr/local/bin/lazydocker
else
    echo "✗ Errore: binario 'lazydocker' non trovato nell'archivio estratto"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Pulizia
rm -rf "$TEMP_DIR"

# 8. Verifica finale
echo "Verifica installazione..."
if command -v lazydocker &> /dev/null; then
    echo "========================================"
    echo "✓ Lazydocker installato con successo!"
    echo "  Versione: $(lazydocker --version)"
    echo "  Percorso: $(which lazydocker)"
    echo "========================================"
    echo ""
    echo "Per avviare Lazydocker:"
    echo "  lazydocker"
    echo ""
    echo "Se ottieni 'permission denied' con Docker:"
    echo "  sudo usermod -aG docker \$USER"
    echo "  (poi disconnettiti e riconnettiti)"
    echo ""
    echo "Suggerimento: crea un alias per usare sudo automaticamente:"
    echo "  echo \"alias lazy='sudo lazydocker'\" >> ~/.bashrc && source ~/.bashrc"
    echo "========================================"
else
    echo "✗ Errore: Installazione fallita"
    echo "  Verifica che /usr/local/bin sia nel tuo PATH"
    exit 1
fi
