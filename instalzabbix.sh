#!/bin/bash

if sudo systemctl is-active mysql &> /dev/null
then
        echo "MySql está instalado"

else
        sudo yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm >/dev/null 2>&1
        sudo percona-release enable-only ps-80 release >/dev/null 2>&1
        sudo percona-release enable tools release >/dev/null 2>&1
        sudo yum install -y percona-server-server >/dev/null 2>&1
        sudo service mysql start >/dev/null 2>&1
        echo "Percona Server for MySQL foi instalado e estartado com sucesso."
fi


#instalação do repositório zabbix

rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm >/dev/null 2>&1
dnf clean all >/dev/null 2>&1

#instale o servidor front e agente
dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent >/dev/null 2>&1


# pega a senha temporária
senhatemporaria=$(sudo cat /var/log/mysqld.log | grep 'A temporary password is generated for root@localhost' | awk -F': ' '{print $2}')

#senha definitiva
senhadefinitiva="GShorus#1995"

#altera para senha definitva
sudo mysql --connect-expired-password  -u root -p"$senhatemporaria" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$senhadefinitiva';" >/dev/null 2>&1


#ia os bancos de dados
sudo mysql -u root -p"$senhadefinitiva" -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by '$senhadefinitiva';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;" >/dev/null 2>&1

#importa o esquema do banco
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p"$senhadefinitiva" zabbix >/dev/null 2>&1


#desativa o log_bin_trust_function_creators
sudo mysql -u root -p"$senhadefinitiva" -e "set global log_bin_trust_function_creators = 0;" >/dev/null 2>&1

# Configure o banco de dados para o servidor Zabbix
 
if [ -f "/etc/zabbix/zabbix_server.conf" ]; then

    sudo sed -i "s/^# DBPassword=/DBPassword=$senhadefinitiva/" /etc/zabbix/zabbix_server.conf

    echo "Senha do Zabbix Server atualizada com sucesso"
else
    echo "O arquivo de configuração /etc/zabbix/zabbix_server.conf não foi encontrado."
fi


# Inicie o servidor Zabbix e os processos do agente
systemctl restart zabbix-server zabbix-agent httpd php-fpm >/dev/null 2>&1
systemctl enable zabbix-server zabbix-agent httpd php-fpm >/dev/null 2>&1

# Configurando o firewall

firewall-cmd --permanent --add-service=http >/dev/null 2>&1
firewall-cmd --reload >/dev/null 2>&1

# parte do script para mostrar o link do zabbix
# Execute o comando 'ip a' e filtra o endereço IP da interface enp0s3
ip_address=$(ip a | awk '/enp0s3/ && /inet / {gsub(/\/.*/, "", $2); print $2}')

# Exiba o endereço para acessar o zabbix
echo "para poder acessar o zabbix acessa com o http:/"$ip_address"/zabbix/setup.php"
