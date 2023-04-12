#!/bin/bash
#
apt update
apt upgrade -y
apt autoremove --purge -y
apt autoclean -y
