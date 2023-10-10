#!/bin/bash

# Verificar se o script é executado como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script precisa ser executado como root."
    exit 1
fi

# Instalar pacotes necessários
apt update
apt install -y apache2 mariadb-server php php-mysql libapache2-mod-php unzip

# Baixar e extrair o OCS Inventory NG
wget https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.6/OCSNG_UNIX_SERVER_2.6.tar.gz
tar -xzf OCSNG_UNIX_SERVER_2.6.tar.gz -C /var/www/html/
mv /var/www/html/OCSNG_UNIX_SERVER_2.6 /var/www/html/ocsinventory

# Configurar permissões
chown -R www-data:www-data /var/www/html/ocsinventory

# Configurar banco de dados
mysql -e "CREATE DATABASE ocsweb CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -e "CREATE USER 'ocs'@'localhost' IDENTIFIED BY '91297686';"
mysql -e "GRANT ALL PRIVILEGES ON ocsweb.* TO 'ocs'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Configurar Apache
cat <<EOL > /etc/apache2/sites-available/ocsinventory.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/ocsinventory
    ServerName localhost

    <Directory /var/www/html/ocsinventory>
        Options +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

a2ensite ocsinventory.conf
a2enmod rewrite
service apache2 restart

# Configurar o OCS Inventory NG
cd /var/www/html/ocsinventory
cp -f install.php.dist install.php
chmod 755 install.php

# Atualizar configurações no arquivo de instalação
sed -i "s/\$dbhost = 'localhost';/\$dbhost = 'localhost';/" /var/www/html/ocsinventory/install.php
sed -i "s/\$LOGIN = '';/\$LOGIN = 'ocs';/" /var/www/html/ocsinventory/install.php
sed -i "s/\$PSWD = '';/\$PSWD = '91297686';/" /var/www/html/ocsinventory/install.php

# Executar o instalador
echo "Acesse http://seu_servidor/ocsinventory/install.php para concluir a instalação."

# Limpar arquivos temporários
rm OCSNG_UNIX_SERVER_2.6.tar.gz

exit 0
