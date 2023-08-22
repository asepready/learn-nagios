```sh
# Create Configuring SNMPv3
net-snmp-config --create-snmpv3-user -ro -A authpass -X privpass -a MD5 -x DES public

## Host Centos Test
snmpwalk -v3 -a MD5 -A authpass -x DES -X privpass -l authPriv -u public 10.0.0.11 | head

# Commands Test Plugin SNMPv2
cd /usr/local/nagios/libexec/
./check_snmp -H 10.0.0.11 -o sysName.0 -C public -t 2 -p 161 -P 3 -L authPriv -U public -a MD5 -A authpass -x DES -X privpass