#! /bin/bash
cd /usr/local/bin
wget https://github.com/abeggi/scripts/raw/main/notify.sh
chmod +x notify.sh
cd /etc/systemd/system/
wget https://github.com/abeggi/scripts/raw/main/notify.service
systemctl enable notify.service
systemctl start notify.service
