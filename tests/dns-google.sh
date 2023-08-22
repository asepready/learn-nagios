cd /usr/local/nagios

# test ping
./libexec/check_ping -H 8.8.8.8 -w 100.0,20% -c 500.0,60% -p 5