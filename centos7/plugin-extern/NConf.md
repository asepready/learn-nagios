```sh
## Download NCconf
cd /tmp/
wget -O nconf-new.tar.gz https://github.com/Bonsaif/new-nconf/archive/refs/tags/nconf-v1.4.0-final2.tar.gz
tar xzf nconf-new.tar.gz
mv new-nconf-nconf-v1.4.0-final2/ nconf
cp -R nconf/ /usr/local/nagios/share

## Install packages and configure files and folders
yum install -y php php-mysql* php-devel perl perl-DBI perl-DBD-mysql
chown root:apache -R /usr/local/nagios/share/nconf
cd /usr/local/nagios/share/nconf/
mv INSTALL.php_ INSTALL.php
chmod -R 777 output/ config/ temp/ static_cfg/
chmod 777 /usr/local/nagios/bin/nagios
 
mkdir /usr/local/nagios/etc/Default_collector
mkdir /usr/local/nagios/etc/global
chgrp -R apache /usr/local/nagios/etc/global
chgrp -R apache /usr/local/nagios/etc/Default_collector
chgrp -R apache /usr/local/nagios/etc/global
chown nagios:nagcmd /usr/local/nagios/var/rw
chown nagios:nagcmd /usr/local/nagios/var/rw/nagios.cmd
chmod 0777 /usr/local/nagios/etc/Default_collector
chmod 0777 /usr/local/nagios/etc/global
chmod 0644 /usr/local/nagios/etc/resource.cfg
systemctl restart httpd

## Database Configuration
mysql -u root -p'vnSPHmEqPcOPe9yr' -e"create database nconf;CREATE USER 'nconf'@'localhost' IDENTIFIED BY 'QUtdZCpwUs4OkQF6a8';GRANT ALL PRIVILEGES ON nconf.* TO 'nconf'@localhost IDENTIFIED BY 'QUtdZCpwUs4OkQF6a8';flush privileges;"

mysql -u root -p'vnSPHmEqPcOPe9yr' nconf < INSTALL_/create_database.sql

# Run this command to ensure that the database has been created:
echo 'show databases;' | mysql -u nconf -p'QUtdZCpwUs4OkQF6a8' -h localhost

# http://your_ip_server/nagios/nconf

# Finished
rm -rf INSTALL* UPDATE*

# configure the deployment.ini file
cp /usr/local/nagios/share/nconf/config/deployment.ini /usr/local/nagios/share/nconf/config/deployment.ini.ori
echo "[extract config]" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "type = local" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "source_file = \"/usr/local/nagios/share/nconf/output/NagiosConfig.tgz\"" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "target_file = \"/tmp/\"" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "action = extract" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "[copy collector config]" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "type = local" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "source_file = \"/tmp/Default_collector/\"" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "target_file = \"/usr/local/nagios/etc/Default_collector/\"" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "action = copy" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "[copy global config]" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "type = local" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "source_file = \"/tmp/global/\"" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "target_file = \"/usr/local/nagios/etc/global/\"" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "action = copy" >> /usr/local/nagios/share/nconf/config/deployment.ini
echo "reload_command = \"sudo /usr/bin/systemctl restart nagios.service\"" >> /usr/local/nagios/share/nconf/config/deployment.ini

# configure the nagios.cfg
sed -i 's/^cfg/#cfg/' /usr/local/nagios/etc/nagios.cfg
echo "" >> /usr/local/nagios/etc/nagios.cfg
echo "# For Nconf configuration" >> /usr/local/nagios/etc/nagios.cfg
echo "cfg_dir=/usr/local/nagios/etc/Default_collector" >> /usr/local/nagios/etc/nagios.cfg
echo "cfg_dir=/usr/local/nagios/etc/global" >> /usr/local/nagios/etc/nagios.cfg

# configure the deploy_local.sh file
cp /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh.ori
rm -f /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "OUTPUT_DIR=\"/usr/local/nagios/share/nconf/output/\"" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "NAGIOS_DIR=\"/usr/local/nagios/\"" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "TEMP_DIR=${NAGIOS_DIR}\"import/\"" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "CONF_ARCHIVE=\"NagiosConfig.tgz\" " >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "if [ ! -e \${TEMP_DIR} ] ; then" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "mkdir -p \${TEMP_DIR}" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "fi" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "if [ \${OUTPUT_DIR}\${CONF_ARCHIVE} -nt \${TEMP_DIR}${CONF_ARCHIVE} ] ; then" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "cp -p \${OUTPUT_DIR}\${CONF_ARCHIVE} \${TEMP_DIR}\${CONF_ARCHIVE}" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "tar -xf \${TEMP_DIR}\${CONF_ARCHIVE} -C \${NAGIOS_DIR}" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "systemctl restart nagios" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "fi" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
echo "exit" >> /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh
sed -i "1i \#\!\/bin\/bash" /usr/local/nagios/share/nconf/ADD-ONS/deploy_local.sh

# commands to configure the sudoers file
echo "" >> /etc/sudoers
echo "ALL ALL = NOPASSWD: /usr/bin/systemctl restart nagios.service" >> /etc/sudoers

# configure the images folder in the nconf application
mkdir -p /usr/local/nagios/share/images/logos/base
cp -rp /usr/local/nagios/share/nconf/img/logos/base/* /usr/local/nagios/share/images/logos/base/
cd /usr/local/nagios/share/images/logos
cp -rp *.gd2 /usr/local/nagios/share/images/logos/base

## Fix massage "Someone else is already generating the configuration"
rm /usr/local/nagios/share/nconf/temp/generate.lock