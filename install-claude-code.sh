#!/bin/bash
# install-claude-code.sh
# Installa Node.js e Claude Code su LXC Debian/Ubuntu minimale
# Dopo l'installazione: aggiungi la tua API key in ~/.bashrc

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Root check
if [ "$EUID" -ne 0 ]; then
  error "Esegui lo script come root"
fi

info "Aggiornamento pacchetti base..."
apt-get update -qq
apt-get install -y -qq curl ca-certificates

# Node.js tramite NodeSource
NODE_MAJOR=22
info "Installazione Node.js ${NODE_MAJOR} via NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - > /dev/null 2>&1
apt-get install -y -qq nodejs

NODE_VER=$(node --version)
NPM_VER=$(npm --version)
info "Node.js installato: ${NODE_VER}, npm: ${NPM_VER}"

# Claude Code
info "Installazione Claude Code..."
npm install -g @anthropic-ai/claude-code --silent

CLAUDE_VER=$(claude --version 2>/dev/null || echo "n/d")
info "Claude Code installato: ${CLAUDE_VER}"

# Configurazione .bashrc
BASHRC="/root/.bashrc"

# API key placeholder (se non già presente)
if ! grep -q "ANTHROPIC_API_KEY" "$BASHRC"; then
  echo "" >> "$BASHRC"
  echo "# Anthropic API Key - sostituisci con la tua chiave" >> "$BASHRC"
  echo "# export ANTHROPIC_API_KEY=sk-ant-..." >> "$BASHRC"
  info "Placeholder API key aggiunto in $BASHRC (commentato)"
else
  warning "ANTHROPIC_API_KEY già presente in $BASHRC, non modificato"
fi

# PATH npm global (precauzione su alcuni sistemi)
NPM_GLOBAL_BIN=$(npm bin -g 2>/dev/null || npm root -g | sed 's/node_modules$/.bin/')
if ! grep -q "npm bin" "$BASHRC" && ! echo "$PATH" | grep -q "$NPM_GLOBAL_BIN"; then
  echo "" >> "$BASHRC"
  echo "# npm global bin path" >> "$BASHRC"
  echo "export PATH=\"\$PATH:$NPM_GLOBAL_BIN\"" >> "$BASHRC"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Installazione completata${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Prossimo passo:"
echo "  1. Apri ~/.bashrc"
echo "  2. Decommenta e compila la riga ANTHROPIC_API_KEY"
echo "  3. Esegui: source ~/.bashrc"
echo "  4. Avvia Claude Code con: claude"
echo ""
