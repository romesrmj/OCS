#!/bin/bash

# Instala o Apache e PHP
apt-get update
apt-get -y install apache2 php

# Instala o MariaDB
apt-get -y install mariadb-server

# Configura o MariaDB
systemctl start mysql
mysql -u root -e "CREATE DATABASE ocsweb"
mysql -u root -e "CREATE USER 'ocsuser'@'localhost' IDENTIFIED BY 'ocspassword'"
mysql -u root -e "GRANT ALL PRIVILEGES ON ocsweb.* TO 'ocsuser'@'localhost'"
mysql -u root -e "FLUSH PRIVILEGES"

# Instala o OCS Inventory NG
cd /tmp
wget https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.7/OCSNG_UNIX_SERVER_2.7.tar.gz
tar -zxvf OCSNG_UNIX_SERVER_2.7.tar.gz
cd OCSNG_UNIX_SERVER_2.7
./setup.sh

# Configura o Apache para o OCS Inventory NG
sed -i 's/dbuser = "ocsuser"/dbuser = "ocsuser"/g' /etc/apache2/conf-available/z-ocsinventory-server.conf
sed -i 's/dbpass = "ocspassword"/dbpass = "ocspassword"/g' /etc/apache2/conf-available/z-ocsinventory-server.conf
ln -s /etc/apache2/conf-available/z-ocsinventory-server.conf /etc/apache2/conf-enabled/z-ocsinventory-server.conf

# Reinicia o Apache
systemctl restart apache2.service
