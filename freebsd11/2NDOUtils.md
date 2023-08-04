# Prerequisites
```sh
cd /usr/ports/databases/mysql57-server
make install clean

# If you use a version of MySQL < 5.7 or MariaDB < 10.2, the following server options must be set:
# add lines on file mysql-clients.cnf and server.cnf
[mysqld]
innodb_file_format=barracuda
innodb_file_per_table=1
innodb_large_prefix=1

echo 'mysql_enable="YES"' >> /etc/rc.conf
service mysql-server start

# Before configuring MySQL / MariaDB you must start the service and configure it to boot on startup.
systemctl enable mariadb.service && systemctl start mariadb.service && systemctl status mariadb.service

# Check that it is running:
ps ax | grep mysql | grep -v grep

# Define MySQL / MariaDB Root Password
/usr/bin/mysqladmin -u root password 'vnSPHmEqPcOPe9yr'

# Login
mysql -u root -p'vnSPHmEqPcOPe9yr'

# Delete Database
DROP USER 'ndoutils'@'localhost';

# Create Database
CREATE DATABASE nagios DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'ndoutils'@'localhost' IDENTIFIED BY 'QUtdZCpwq0lG1F6a8';
GRANT USAGE ON *.* TO 'ndoutils'@'localhost' IDENTIFIED BY 'QUtdZCpwq0lG1F6a8' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0; 
GRANT ALL PRIVILEGES ON nagios.* TO 'ndoutils'@'localhost' WITH GRANT OPTION ; 

# Now you can exit the local MySQL / MariaDB database engine interface.
\q

# Run this command to ensure that the database has been created:
echo 'show databases;' | mysql -u ndoutils -p'QUtdZCpwq0lG1F6a8' -h localhost
 
# Linux Kernel Settings
# First create a backup copy of the /etc/sysctl.conf file:
cp /etc/sysctl.conf /opt/sysctl.conf.orig

# Now make the required changes:
sed -i '/msgmnb/d' /etc/sysctl.conf
sed -i '/msgmax/d' /etc/sysctl.conf
sed -i '/shmmax/d' /etc/sysctl.conf
sed -i '/shmall/d' /etc/sysctl.conf
printf "\n\nkernel.msgmnb = 131072000\n" >> /etc/sysctl.conf
printf "kernel.msgmax = 131072000\n" >> /etc/sysctl.conf
printf "kernel.shmmax = 4294967295\n" >> /etc/sysctl.conf
printf "kernel.shmall = 268435456\n" >> /etc/sysctl.conf
sysctl -e -p /etc/sysctl.conf
  
# Downloading NDOUtils Source
cd /tmp
wget -O ndoutils.tar.gz https://github.com/NagiosEnterprises/ndoutils/releases/download/ndoutils-2.1.3/ndoutils-2.1.3.tar.gz
tar xzf ndoutils.tar.gz

# Compile NDOUtils
cd /tmp/ndoutils-2.1.3/
./configure 
make all

# Install Binaries
make install

# Initialize Database
cd db/
./installdb -u 'ndoutils' -p 'QUtdZCpwq0lG1F6a8' -h 'localhost' -d nagios
cd .. 

# Install Configuration Files
make install-config
mv /usr/local/nagios/etc/ndo2db.cfg-sample /usr/local/nagios/etc/ndo2db.cfg
sed -i 's/^db_user=.*/db_user=ndoutils/g' /usr/local/nagios/etc/ndo2db.cfg
sed -i 's/^db_pass=.*/db_pass=QUtdZCpwq0lG1F6a8/g' /usr/local/nagios/etc/ndo2db.cfg
mv /usr/local/nagios/etc/ndomod.cfg-sample /usr/local/nagios/etc/ndomod.cfg

# Install Service / Daemon
make install-init
systemctl enable ndo2db.service && systemctl start ndo2db.service

# Update Nagios To Use NDO Broker Module
printf "\n\n# NDOUtils Broker Module\n" >> /usr/local/nagios/etc/nagios.cfg
printf "broker_module=/usr/local/nagios/bin/ndomod.o config_file=/usr/local/nagios/etc/ndomod.cfg\n" >> /usr/local/nagios/etc/nagios.cfg 

# Restart Nagios
systemctl restart nagios.service && systemctl status nagios.service

# Verifi
grep ndo /usr/local/nagios/var/nagios.log
echo 'select * from nagios.nagios_logentries;' | mysql -u ndoutils -p'QUtdZCpwq0lG1F6a8'

# Service Commands
systemctl start ndo2db.service
systemctl stop ndo2db.service
systemctl restart ndo2db.service
systemctl status ndo2db.service
