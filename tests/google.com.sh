cd /usr/local/nagios

# test http/https
./libexec/check_http -H www.google.com -w 100.0,20% -c 500.0,60% -t 10