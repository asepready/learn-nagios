### Create MRTG GENERATE
sudo mkdir -p /usr/local/nagios/share/stats/s1 && 
cfgmaker --global "WorkDir: /usr/local/nagios/share/stats/s1" --enablesnmpv3 --username=public --privpassword=privpass --privprotocol=des --authprotocol=md5 --authpassword=authPriv --contextengineid=0x2e81200 --snmp-options=:::::3 --global "Options[_]: growright, bits" --ifref=descr --ifdesc=descr public@10.0.0.11 > /etc/mrtg/s1_snmpv3.cfg
 && vi /etc/mrtg/s1_snmpv3.cfg

## Running Script for display warning
for (( i=1 ; i <= 3 ; i++ )); do env LANG=C mrtg /etc/mrtg/s1_snmpv3.cfg; done

## Generate index file
indexmaker --columns=1 /etc/mrtg/s1_snmpv3.cfg > /usr/local/nagios/share/stats/s1/index.html

## Add crond.d
### cat /etc/cron.d/mrtg
echo '*/5 * * * * root LANG=C LC_ALL=C /usr/bin/mrtg /etc/mrtg/s1_snmpv3.cfg --confcache-file /var/lib/mrtg/s1_snmpv3.ok' >> /etc/cron.d/mrtg

### make sure crond is running and you are done with configuration:
systemctl list-dependencies mrtg

### turn on crond service:
systemctl enable crond.service && systemctl start crond.service && systemctl status crond.service
systemctl enable mrtg.service && systemctl start mrtg.service && systemctl status mrtg.service