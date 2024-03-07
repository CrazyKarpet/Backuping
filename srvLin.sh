#!/bin/bash

## Install apache2

# Vérifier si l'utilisateur est root
if [ "$(id -u)" != "0" ]; then
    echo "Ce script doit être exécuté en tant que root." 1>&2
    exit 1
fi

# Mise à jour des packages
apt-get update

# Installation d'Apache2
apt-get install -y apache2

# Démarrer Apache2
systemctl start apache2

# Activer Apache2 au démarrage du système
systemctl enable apache2

echo "L'installation d'Apache2 sur Debian est terminée."






## Install Serveur de fichier

# Installation de Samba
apt update
apt install samba

# Configuration de Samba
cp /etc/samba/smb.conf /etc/samba/smb.conf_backup # Sauvegarde du fichier de configuration original
cat << EOF | tee /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = Samba Server %v
   netbios name = srv-web
   security = user
   map to guest = Bad User
   dns proxy = no

[RH]
   comment = Shared Folder
   path = /srv/RH
   browseable = yes
   writable = yes
   guest ok = yes
   read only = no
   create mask = 0777
   directory mask = 0777
EOF

# Création du répertoire partagé
mkdir -p /srv/RH
chmod -R 777 /srv/RH


mkdir -p /srv/RH/exemple1
touch /srv/RH/File1

# Redémarrage du service Samba
systemctl restart smbd



## Install bareos client


CLIENT_PASSWD='Pa$$w0rd'

apt-get update && apt-get install -y gnupg2

wget https://download.bareos.org/current/Debian_12/add_bareos_repositories.sh
bash add_bareos_repositories.sh
rm ./add_bareos_repositories.sh

apt-get update && apt-get install -y bareos-filedaemon

cat <<EOF > /etc/bareos/bareos-fd.d/director/bareos-dir.conf
Director {
  Name = bareos-dir
  Password = "${CLIENT_PASSWD}"
  Description = "Allow the configured Director to access this file daemon."
}
EOF

systemctl enable --now bareos-filedaemon.service

echo '192.168.16.15 backup-srv01' 1>>/etc/hosts
