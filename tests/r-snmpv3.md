Host Centos Test
```sh
snmpwalk -v3 -a MD5 -A YUkVXTnIBBlGvOeU -x DES -X dcyoioisdjRalrUN -l authPriv -u public 172.19.1.13 | head
```

Commands Test Plugin SNMPv2
```sh server nagios
cd /usr/local/nagios/libexec/

./check_mrtgtraf -F /usr/local/nagios/share/stats/pangkalbalam/172.19.1.39_ether1_internet.log -a AVG -w 1000000,1000000 -c 5000000,5000000 -e 5

./check_snmp -H 172.19.1.13 -o 1.3.6.1.4.1.14988.1.1.6.1.0 -C public -t 2 -p 161 -P 3 -L authPriv -U public -a MD5 -A YUkVXTnIBBlGvOeU -x DES -X dcyoioisdjRalrUN