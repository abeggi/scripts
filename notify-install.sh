#! /bin/bash
cd /usr/local/bin
rm /usr/local/bin/notify.sh
wget https://github.com/abeggi/scripts/raw/main/notify.sh
chmod +x notify.sh
cd /etc/systemd/system/
systemctl disable notify.service
rm /etc/systemd/system/notify.service
wget https://github.com/abeggi/scripts/raw/main/notify.service
systemctl enable notify.service
systemctl start notify.service
