```sh
#
cat > /etc/resolv.conf <<EOF
nameserver 10.0.0.254
nameserver 8.8.8.8
nameserver 8.8.4.4

EOF

#
cat > /etc/network/interfaces.d/ens4<<EOF
# The primary network interface
auto ens4
iface ens4 inet static
   address 10.0.0.11
   netmask 255.255.255.0
   gateway 10.0.0.254
#   dns-domain google.com
#   dns-nameservers 10.0.0.254 8.8.8.8 8.8.4.4

EOF

# Download SNMP on Debian 10
#apt install network-manager
apt install snmpd snmp libsnmp-dev
apt install ufw

# Configuring SNMP
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig
cat > /etc/snmp/snmpd.conf <<EOF
rocommunity public
syslocation master
syscontact master@localhost
EOF

# Run service
systemctl enable snmpd && systemctl start snmpd && systemctl status snmpd

## Allow Firewall
sudo systemctl enable ufw && sudo systemctl start ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 161/udp
sudo ufw allow 5666/tcp
sudo ufw show added
sudo ufw enable

# Create Configuring SNMPv3
systemctl stop snmpd
net-snmp-config --create-snmpv3-user -ro -A authpass -X privpass -a MD5 -x DES public

systemctl start snmpd
snmpwalk -v3 -a MD5 -A authpass -x DES -X privpass -l authPriv -u public localhost
## test
snmpwalk -v3 -a MD5 -A authpass -x DES -X privpass -l authPriv -u public localhost -o sysDescr.0
snmpwalk -v3 -a MD5 -A YUkVXTnIBBlGvOeU -x DES -X dcyoioisdjRalrUN -l authPriv -u public localhost

# Download and Install Nagios Plugins
```sh
apt install -y xinetd

cd /tmp
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.2/nrpe-4.0.2.tar.gz
tar zxf nrpe-4.0.2.tar.gz
cd nrpe-4.0.2/
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make all
make install-groups-users
make install
make install-plugin
make install-daemon
make install-config
make install-inetd
make install-init

### RUn service NRPE
systemctl enable xinetd && systemctl start xinetd systemctl status xinetd # systemd
systemctl enable nrpe && systemctl start nrpe # systemd
systemctl daemon-reload

### Enable Firewall
firewall-cmd --zone=public --add-port=5666/tcp --permanent
firewall-cmd --reload

### Create Verify
ln -s /usr/local/nagios/libexec/check_nrpe /bin/check_nrpe
check_nrpe -H 127.0.0.1 -4
```
### Enable SSL/TLS
```sh
mkdir -p -m 750 /usr/local/nagios/etc/ssl
chown root:nagios /usr/local/nagios/etc/ssl
cd /usr/local/nagios/etc/ssl

## Create Certificate Authority
mkdir -m 750 ca
chown root:root ca
cd /usr/local/nagios/etc/ssl/ca
    openssl req -x509 -newkey rsa:4096 -keyout ca_key.pem \
       -out ca_cert.pem -utf8 -days 3650

cd /usr/local/nagios/etc/ssl
    mkdir demoCA
    mkdir demoCA/newcerts
    touch demoCA/index.txt
    echo "01" > demoCA/serial
    chown -R root:root demoCA
    chmod 700 demoCA
    chmod 700 demoCA/newcerts
    chmod 600 demoCA/serial
    chmod 600 demoCA/index.txt

## Create NRPE Server Certificate Requests
cd /usr/local/nagios/etc/ssl
mkdir -m 750 server_certs
chown root:nagios server_certs
cd /usr/local/nagios/etc/ssl/server_certs
    openssl req -new -newkey rsa:2048 -keyout db_server.key \
       -out db_server.csr -nodes

    openssl req -new -newkey rsa:2048 -keyout bobs_workstation.key \
       -out bobs_workstation.csr -nodes

cd /usr/local/nagios/etc/ssl
    openssl ca -days 365 -notext -md sha256 \
       -keyfile ca/ca_key.pem -cert ca/ca_cert.pem \
       -in server_certs/db_server.csr \
       -out server_certs/db_server.pem
    
    chown root:nagios server_certs/db_server.pem
    chmod 440 server_certs/db_server.pem

    openssl ca -days 365 -notext -md sha256 \
       -keyfile ca/ca_key.pem -cert ca/ca_cert.pem \
       -in server_certs/bobs_workstation.csr \
       -out server_certs/bobs_workstation.pem
    
    chown root:nagios server_certs/bobs_workstation.pem
    chmod 440 server_certs/bobs_workstation.pem

## Create NRPE Client Certificate Requests
mkdir -m 750 client_certs
chown root:nagios client_certs
cd /usr/local/nagios/etc/ssl/client_certs
    openssl req -new -newkey rsa:2048 -keyout nag_serv.key \
       -out nag_serv.csr -nodes

    cd /usr/local/nagios/etc/ssl
    openssl ca -extensions usr_cert -days 365 -notext -md sha256 \
       -keyfile ca/ca_key.pem -cert ca/ca_cert.pem \
       -in client_certs/nag_serv.csr \
       -out client_certs/nag_serv.pem
       
    chown root:nagios client_certs/nag_serv.pem
    chmod 440 client_certs/nag_serv.pem
```
### nano /usr/local/nagios/etc/nrpe.cfg
```sh file
#!/usr/local/nagios/etc/nrpe.cfg
# SSL/TLS OPTIONS
ssl_version=SSLv2+

# SSL USE ADH
ssl_use_adh=1

# SSL CIPHER LIST
ssl_cipher_list=ALL:!MD5:@STRENGTH
ssl_cipher_list=ALL:!MD5:@STRENGTH:@SECLEVEL=0
ssl_cipher_list=ALL:!aNULL:!eNULL:!SSLv2:!LOW:!EXP:!RC4:!MD5:@STRENGTH

# SSL Certificate and Private Key Files
ssl_cacert_file=/etc/ssl/servercerts/ca-cert.pem
ssl_cert_file=/etc/ssl/servercerts/nagios-cert.pem
ssl_privatekey_file=/etc/ssl/servercerts/nagios-key.pem

# SSL USE CLIENT CERTS
# This options determines client certificate usage.
# Values: 0 = Don't ask for or require client certificates (default)
#         1 = Ask for client certificates
#         2 = Require client certificates

#ssl_client_certs=0

# SSL LOGGING
# This option determines which SSL messages are send to syslog. OR values
# together to specify multiple options.

# Values: 0x00 (0)  = No additional logging (default)
#         0x01 (1)  = Log startup SSL/TLS parameters
#         0x02 (2)  = Log remote IP address
#         0x04 (4)  = Log SSL/TLS version of connections
#         0x08 (8)  = Log which cipher is being used for the connection
#         0x10 (16) = Log if client has a certificate
#         0x20 (32) = Log details of client's certificate if it has one
#         -1 or 0xff or 0x2f = All of the above

#ssl_logging=0x00
```
## Verify the plugins in below path
```sh
ls /usr/local/nagios/libexec/

systemctl restart httpd
systemctl restart nagios

/usr/local/nagios/libexec/check_nrpe -H localhost -c check_users
/usr/local/nagios/libexec/check_nrpe -H localhost -c check_load
/usr/local/nagios/libexec/check_nrpe -H localhost -c check_hda1
/usr/local/nagios/libexec/check_nrpe -H localhost -c check_total_procs
/usr/local/nagios/libexec/check_nrpe -H localhost -c check_zombie_procs
```

## Access Nagios Web console
http://NagiosServerIP/nagios
