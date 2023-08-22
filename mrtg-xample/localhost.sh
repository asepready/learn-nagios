## MRTG Nagios 
sudo mkdir -p /usr/local/nagios/share/stats

## vi /usr/local/nagios/etc/mrtg.cfg
echo'WorkDir: /usr/local/nagios/share/stats' >> /usr/local/nagios/etc/mrtg.cfg
echo'Options[_]: growright, bits' >> /usr/local/nagios/etc/mrtg.cfg

## Running Script for display warning
for (( i=1 ; i <= 3 ; i++ )); do env LANG=C mrtg /usr/local/nagios/etc/mrtg.cfg; done

## Generate index file
indexmaker --columns=1 /usr/local/nagios/etc/mrtg.cfg > /usr/local/nagios/share/stats/index.html

## Add crond.d
### cat /etc/cron.d/mrtg
echo '*/5 * * * * root LANG=C LC_ALL=C /usr/bin/mrtg /usr/local/nagios/etc/mrtg.cfg --confcache-file /var/lib/mrtg/s1-snmpv3.ok' >> /etc/cron.d/mrtg

### make sure crond is running and you are done with configuration:
systemctl list-dependencies mrtg

### turn on crond service:
systemctl enable crond.service && systemctl start crond.service && systemctl status crond.service
systemctl enable mrtg.service && systemctl start mrtg.service && systemctl status mrtg.service