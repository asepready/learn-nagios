```sh
#########################################################################################
# SNMP INTERFACE
# http://nagios.manubulon.com/

yum install git net-snmp* -y 
yum install 'perl(Net::SNMP)' -y

cd /tmp
wget https://github.com/SteScho/manubulon-snmp/archive/refs/tags/v2.1.0.tar.gz
tar xzf v2.1.0.tar.gz
cd manubulon-snmp-2.1.0/
chmod 777 *
