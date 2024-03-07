#!/bin/bash

BAREOS_WEBUI_USERNAME='admin'
BAREOS_WEBUI_PASSWD='Pa$$w0rd'

apt-get update
apt-get install -y postgresql gnupg2 rsync
wget https://download.bareos.org/current/Debian_12/add_bareos_repositories.sh
bash add_bareos_repositories.sh
rm ./add_bareos_repositories.sh
apt-get update

apt-get install -y bareos
systemctl enable --now bareos-director.service
systemctl enable --now bareos-storage.service
systemctl enable --now bareos-filedaemon.service
apt-get install -y bareos-webui php8.2 libapache2-mod-php

cat << EOF > /etc/bareos/bareos-dir.d/console/admin.conf
Console {
  Name = "${BAREOS_WEBUI_USERNAME}"
  Password = "${BAREOS_WEBUI_PASSWD}"
  Profile = "webui-admin"
  TlsEnable = false
}
EOF

systemctl restart bareos-director.service
systemctl restart apache2.service
