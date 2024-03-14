#!/bin/bash

CLIENT_PASSWD='Pa$$w0rd'
WIN_CLIENT_NAME='wincli'
WIN_CLIENT_IP='192.168.122.110'
LIN_CLIENT_NAME='srvfile-srvweb'
LIN_CLIENT_IP='192.168.122.158'

echo "configure add client name=\"${WIN_CLIENT_NAME}\" address=\"${WIN_CLIENT_IP}\" password=\"${CLIENT_PASSWD}\"" | bconsole 1>/dev/null

cat <<EOF > /etc/bareos/bareos-dir.d/job/BackupWindowsFull.conf
Job {
  Name = "BackupWindowsFull"
  Type = Backup
  Client = ${WIN_CLIENT_NAME}
  FileSet= "WindowsFull"
  Storage = File
  Level = Full
  Pool = Full
  Messages = Standard
}
EOF

cat <<EOF > /etc/bareos/bareos-dir.d/fileset/WindowsFull.conf
FileSet {
  Name = "WindowsFull"
  Enable VSS = yes
  Include {
    Options {
      Signature = MD5
      Drive Type = fixed
      IgnoreCase = yes
      WildFile = "[A-Z]:/hiberfil.sys"
      WildFile = "[A-Z]:/pagefile.sys"
      WildFile = "[A-Z]:/swapfile.sys"
      WildDir = "[A-Z]:/RECYCLER"
      WildDir = "[A-Z]:/$RECYCLE.BIN"
      WildDir = "[A-Z]:/System Volume Information"
      Exclude = yes
    }
    File = "[A-Z]:/"
  }
}
EOF

echo "configure add client name=\"${CLIENT_NAME}\" address=\"${CLIENT_IP}\" password=\"${CLIENT_PASSWD}\"" | bconsole 1>/dev/null

cat <<EOF 1>/etc/bareos/bareos-dir.d/job/BackupSambaFull.conf
Job {
  Name = "BackupSambaFull"
  Type = Backup
  Client = ${LIN_CLIENT_NAME}
  FileSet= "srvfile"
  Storage = File
  Level = Full
  Pool = Full
  Messages = Standard
}
EOF

cat <<EOF 1>/etc/bareos/bareos-dir.d/job/BackupWebFull.conf
Job {
  Name = "BackupWebFull"
  Type = Backup
  Client = ${LIN_CLIENT_NAME}
  FileSet= "srvweb"
  Storage = File
  Level = Full
  Pool = Full
  Messages = Standard
}
EOF

cat <<EOF 1>/etc/bareos/bareos-dir.d/fileset/srvfile.conf
FileSet {
  # A fork from LinuxAll FileSet
  Name = "srvfile"
  Description = "Backup all server files."
  Include {
    Options {
      Signature = MD5
      compression = gzip
      One FS = No
      FS Type = btrfs
      FS Type = ext2
      FS Type = ext3
      FS Type = ext4
      FS Type = reiserfs
      FS Type = jfs
      FS Type = vfat
      FS Type = xfs
      FS Type = zfs
    }
    File = /srv/RH
  }
}
EOF

cat <<EOF 1>/etc/bareos/bareos-dir.d/fileset/srvweb.conf
FileSet {
  # A fork from LinuxAll FileSet
  Name = "srvweb"
  Description = "Backup all serveur web files."
  Include {
    Options {
      Signature = MD5
      compression = gzip
      One FS = No
      FS Type = btrfs
      FS Type = ext2
      FS Type = ext3
      FS Type = ext4
      FS Type = reiserfs
      FS Type = jfs
      FS Type = vfat
      FS Type = xfs
      FS Type = zfs
    }
    File = /var/www
    File = /etc/apache2
  }
}
EOF

chown bareos:bareos /etc/bareos/bareos-dir.d/job/*.conf
chmod 0640 /etc/bareos/bareos-dir.d/job/*.conf

chown bareos:bareos /etc/bareos/bareos-dir.d/fileset/*.conf
chmod 0640 /etc/bareos/bareos-dir.d/fileset/*.conf

systemctl restart bareos-director.service
