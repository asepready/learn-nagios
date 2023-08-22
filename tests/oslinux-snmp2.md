Host Centos Test
```sh
snmpwalk -c public -v 2c 10.0.0.2 | head
```

Commands Test Plugin SNMPv2
```sh server nagios
./check_snmp_load.pl -H 10.0.0.2 -C public -T netsc -w 90 -c 95
Output: CPU used 2.0% (<90) : OK

./check_snmp_storage.pl -H 10.0.0.2 -C public -m /boot -r -w 90 -c 95
Output: /boot: 7%used(131MB/1952MB) (<90%) : OK

./check_snmp_mem.pl -H 10.0.0.2 -C public -w 90,20 -c 95,30 -f
Output: Ram : 11%, Swap : 0% : ; OK | ram_used=405796;3463924;3656364;0;3848804 swap_used=0;1677721;2516581;0;8388604

./check_snmp_process.pl -H 10.0.0.2 -C public -n http -f -w 3,7 -c 0,8 -m 15,25 -u 10,20
Output: 5 processes matching http (> 3) (<= 7):OK, Mem : 13.5MB OK, CPU : 0% OK

./check_snmp_int.pl -H 10.0.0.2 -C public -n zzzz -v
Output: OID : 1.3.6.1.2.1.2.2.1.2.2, Desc : ens3
        OID : 1.3.6.1.2.1.2.2.1.2.1, Desc : lo

./check_snmp_int.pl -H 10.0.0.2 -C public -n ens3
Output: ens33:UP:1 UP: OK

./check_snmp_int.pl -H 10.0.0.2 -C public -n ens3 -k -w 200,400 -c 500,600
Output:ens33:UP (0.1KBps/0.0KBps):1 UP: OK

./check_mrtg_2 /tmp/mrtg/127.0.0.1.log