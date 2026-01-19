#!/bin/bash
set -e

# Assicura che apt non chieda input
export DEBIAN_FRONTEND=noninteractive

# Aggiornamento completo e pulizia
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove --purge -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*
