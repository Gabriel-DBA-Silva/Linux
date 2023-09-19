#!/bin/bash

if sudo service mysql status | grep active
then
        echo "MySql está instalado"

else
        sudo yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
        sudo percona-release enable-only ps-80 release
        sudo percona-release enable tools release
        sudo yum install -y percona-server-server
        sudo service mysql start
        echo "Percona Server for MySQL foi instalado e estartado com sucesso."
fi


#instalação do repositório zabbix

rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
dnf clean all

#instale o servidor front e agente
dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent


# pega a senha temporária
senhatemporaria=$(sudo cat /var/log/mysqld.log | grep 'A temporary password is generated for root@localhost' | awk -F': ' '{print $2}')

#senha definitiva
senhadefinitiva="GShorus#1995"

#altera para senha definitva
sudo mysql --connect-expired-password  -u root -p"$senhatemporaria" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$senhadefinitiva';"


#ia os bancos de dados
sudo mysql -u root -p"$senhadefinitiva" -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by '$senhadefinitiva';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;"

#importa o esquema do banco
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p"$senhadefinitiva" zabbix


#desativa o log_bin_trust_function_creators
sudo mysql -u root -p"$senhadefinitiva" -e "set global log_bin_trust_function_creators = 0;"

# Configure o banco de dados para o servidor Zabbix
 
if [ -f "/etc/zabbix/zabbix_server.conf" ]; then

    sudo sed -i "s/^# DBPassword=/DBPassword=$senhadefinitiva/" /etc/zabbix/zabbix_server.conf

    echo "Senha do Zabbix Server atualizada com sucesso"
else
    echo "O arquivo de configuração /etc/zabbix/zabbix_server.conf não foi encontrado."
fi


# Inicie o servidor Zabbix e os processos do agente
systemctl restart zabbix-server zabbix-agent httpd php-fpm
systemctl enable zabbix-server zabbix-agent httpd php-fpm

# Configurando o firewall

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# parte do script para mostrar o link do zabbix
# Execute o comando 'ip a' e filtra o endereço IP da interface enp0s3
ip_address=$(ip a | awk '/enp0s3/ && /inet / {gsub(/\/.*/, "", $2); print $2}')

# Exiba o endereço para acessar o zabbix
echo "para poder acessar o zabbix acessa com o http:/"$ip_address"/zabbix/setup.php"

