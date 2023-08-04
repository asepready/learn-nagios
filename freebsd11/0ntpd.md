## Install NTP Packages
```sh
yum -y update 
yum -y install -y ntp yum-utils
```
## Configure NTP Servers
vi /etc/ntp.conf
```sh
....
#server 0.centos.pool.ntp.org iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst
server 0.id.pool.ntp.org iburst
server 1.id.pool.ntp.org iburst
server 2.id.pool.ntp.org iburst
server 3.id.pool.ntp.org iburst
....

systemctl enable ntpd && systemctl start ntpd && systemctl status ntpd
ntpq -p
timedatectl set-timezone Asia/Jakarta
```