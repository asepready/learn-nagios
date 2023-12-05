```sh
# Prerequisites
pkg install apache24 mod_php81 php81-gd p5-Apache-Htpasswd-1.9_2

## conf apache24
cat >> /usr/local/etc/apache24/httpd.conf << 'EOL'
<FilesMatch "\.php$">
    SetHandler application/x-httpd-php
</FilesMatch>
<FilesMatch "\.phps$">
    SetHandler application/x-httpd-php-source
</FilesMatch>

'EOL'
``````

echo "<? phpinfo(); ?>" >> /usr/local/www/apache24/data/test.php
service apache24 onestart

rehash
# Downloading the Source
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.14.tar.gz
tar xzf nagioscore.tar.gz

# Compile
cd /tmp/nagioscore-nagios-4.4.14/
./configure --with-command-group=nagcmd
make all

# Create User And Group
make install-groups-users
usermod -a -G nagios apache
 
# Install Binaries
make install
 
# Install Service / Daemon
make install-init
systemctl enable nagios.service

# Install Command Mode
make install-commandmode
 
# Install Configuration Files
make install-config
make install-exfoliation

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
systemctl enable httpd.service && systemctl start httpd.service
systemctl start nagios.service
#########################################################################################
# Installing The Nagios Plugins
yum install -y net-snmp*
yum install -y 'perl(Net::SNMP)'

# Downloading The Source
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.6.tar.gz
tar zxf nagios-plugins.tar.gz

# Compile + Install
cd /tmp/nagios-plugins-release-2.4.6/
./tools/setup
./configure --prefix=/usr/local/nagios --with-cgiurl=/nagios/cgi-bin
make all
make install
 

#########################################################################################
# SNMP INTERFACE
# http://nagios.manubulon.com/
cd /tmp
wget https://github.com/SteScho/manubulon-snmp/archive/refs/tags/v2.1.0.tar.gz
tar xzf v2.1.0.tar.gz
cd manubulon-snmp-2.1.0/
chmod 777 *

# Service / Daemon Commands
systemctl restart nagios.service && systemctl status nagios.service

## Create terminal Verify the Nagios config
echo "/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg" > /usr/bin/verifynagios
chmod 777 /bin/verifynagios
verifynagios

# HTTPD Config add lines /etc/httpd/conf/httpd.conf
echo '' >> /etc/httpd/conf/httpd.conf
echo '#Enable SSL' >> /etc/httpd/conf/httpd.conf
echo 'RewriteEngine On' >> /etc/httpd/conf/httpd.conf
echo 'RewriteCond %{HTTPS} off' >> /etc/httpd/conf/httpd.conf
echo 'RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}' >> /etc/httpd/conf/httpd.conf


#Enable SSL Nagios
sed -i 's/#  SSLRequireSSL/  SSLRequireSSL/g' /etc/httpd/conf.d/nagios.conf

ln -s /usr/local/nagios/share/* /var/www/html/