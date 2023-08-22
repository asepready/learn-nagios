```sh
## Add MRTG to Nagios
yum install mrtg net-snmp net-snmp-utils

cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.ori
# replice /etc/snmp/snmpd.conf
cat > /etc/snmp/snmpd.conf <<EOF
rocommunity public
syslocation master
syscontact master@localhost
EOF

chkconfig snmpd on
service snmpd restart
## Verify SNMP 
snmpwalk -v 2c -c public 10.0.0.11 IP-MIB::ipAdEntIfIndex

# cfgmaker commands to generate a mrtg configuration file:
sudo mkdir -p /usr/local/nagios/share/stats/s1 && cfgmaker --global "WorkDir: /usr/local/nagios/share/stats/s1" --global "Options[_]: growright, bits" --ifref=descr --ifdesc=descr public@10.0.0.11 > /etc/mrtg/s1_snmp.cfg && vi /etc/mrtg/s1_snmp.cfg

## Running Script for display warning & ## Generate index file
for (( i=1 ; i <= 3 ; i++ )); do env LANG=C mrtg /etc/mrtg/s1_snmp.cfg; done && indexmaker --columns=1 /etc/mrtg/s1_snmp.cfg > /usr/local/nagios/share/stats/s1/index.html

## Add crond.d
### 
echo '*/5 * * * * root LANG=C LC_ALL=C /usr/bin/mrtg /etc/mrtg/s1_snmp.cfg --confcache-file /var/lib/mrtg/s1_snmp.ok' >> /etc/cron.d/mrtg && cat /etc/cron.d/mrtg

### make sure crond is running and you are done with configuration:
systemctl list-dependencies mrtg

### turn on crond service:
systemctl enable crond.service && systemctl start crond.service && systemctl status crond.service
systemctl enable mrtg.service && systemctl start mrtg.service && systemctl status mrtg.service
 
