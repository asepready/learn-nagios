## CentOS 7
```sh
# Security-Enhanced Linux
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# Prerequisites
yum install -y epel-release 
yum install -y wget gcc glibc glibc-common unzip httpd mod_ssl gd gd-devel perl postfix
yum install -y openssl-devel 

yum install -y php php-imap php-opcache php-devel php-gd php-ldap php-mbstring php-pdo php-pdo-dblib php-mysqlnd php-pgsql php-pear php-pecl-ssh2 php-pgsql php-process php-snmp php-xml php-odbc php-imagick
sed -i "s/;date.timezone = /date.timezone = asia/jakarta/g" /etc/php.ini

## Create Nagios user and group
groupadd nagcmd
groupadd nagios
useradd -g nagios -G nagcmd nagios
usermod -a -G nagios apache

# Downloading the Source
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.13.tar.gz
tar xzf nagioscore.tar.gz

# Compile
cd /tmp/nagioscore-nagios-4.4.13/
./configure --with-command-group=nagcmd
make all
 
# Install Binaries
make install
 
# Install Service / Daemon
make install-daemoninit
systemctl enable httpd.service

# Install Command Mode
make install-commandmode
 
# Install Configuration Files
make install-config

# Install Apache Config Files
make install-webconf

# Configure Firewall
firewall-cmd --zone=public --add-port=80/tcp
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload
 
# Create nagiosadmin User Account
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Start Apache Web Server
systemctl start httpd.service
systemctl start nagios.service
#########################################################################################
# Installing The Nagios Plugins
yum install -y net-snmp*
yum install -y 'perl(Net::SNMP)'

# Downloading The Source
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.4.tar.gz
tar zxf nagios-plugins.tar.gz

# Compile + Install
cd /tmp/nagios-plugins-release-2.4.4/
./tools/setup
./configure
make
make install
 
# Service / Daemon Commands
systemctl restart nagios.service
systemctl status nagios.service

## Create terminal Verify the Nagios config
echo "/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg" > /usr/bin/verifynagios
chmod 777 /bin/verifynagios
verifynagios

# HTTPD Config add lines /etc/httpd/conf/httpd.conf
#Enable SSL
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}

#Enable SSL Nagios
