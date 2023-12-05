```sh
yum install -y dnf-plugins-core
yum install -y epel-release
yum repolist
yum-config-manager enabled PowerTools
yum install -y rrdtool-devel boost boost-thread boost-devel sqlite libstdc++* libstdc++-static php-gd php-gettext php-mbstring php-session php-json php-pdo php-mysqlnd rsync gcc-c++ graphviz libsqlite3x.*
touch /usr/local/nagios/var/rw/live
chown nagios:apache /usr/local/nagios/var/rw/live

# Upgrade C++
yum install -y centos-release-scl
yum install devtoolset-7-gcc-c++ --enablerepo='centos-sclo-rh'
scl enable devtoolset-7 'bash'
which gcc

# Install MKLiveStatus
cd /tmp
wget --no-check-certificate https://download.checkmk.com/checkmk/1.5.0p25/mk-livestatus-1.5.0p25.tar.gz
tar xzf mk-livestatus-1.5.0p25.tar.gz
cd mk-livestatus-1.5.0p25
autoreconf -f -i
./configure --with-nagios4
make
make install

#!/usr/local/nagios/etc/nagios.cfg
broker_module=/usr/local/lib/mk-livestatus/livestatus.o /usr/local/nagios/var/rw/live
event_broker_options=-1

# Install Nagvis
cd /tmp/
wget http://www.nagvis.org/share/nagvis-1.9.28.tar.gz
tar -zxvf nagvis-1.9.28.tar.gz
cd nagvis-1.9.28
./install.sh