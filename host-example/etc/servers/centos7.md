```sh
# Download SNMP on Debian 10
yum install git net-snmp* -y 

# Configuring SNMP
cp /etc/snmp/snmpd.conf /opt/snmpd.conf.orig
cat > /etc/snmp/snmpd.conf <<EOF
rocommunity public
syslocation master
syscontact master@localhost
EOF

# Run service
systemctl enable snmpd && systemctl start snmpd && systemctl status snmpd

## Allow Firewall
firewall-cmd --zone=public --add-port=161/udp
firewall-cmd --zone=public --add-port=161/udp --permanent
firewall-cmd --zone=public --add-port=162/udp
firewall-cmd --zone=public --add-port=162/udp --permanent
firewall-cmd --reload
firewall-cmd --list-ports

# Create Configuring SNMPv3
systemctl stop snmpd
net-snmp-config --create-snmpv3-user -ro -A authpass -X privpass -a MD5 -x DES public

systemctl start snmpd
snmpwalk -v3 -a MD5 -A authpass -x DES -X privpass -l authPriv -u public localhost
## test
snmpwalk -v3 -a MD5 -A authpass -x DES -X privpass -l authPriv -u public localhost
snmpwalk -v3 -a MD5 -A YUkVXTnIBBlGvOeU -x DES -X dcyoioisdjRalrUN -l authPriv -u public localhost
