```sh
#########################################################################################
# SNMP INTERFACE
# http://nagios.manubulon.com/

yum install git net-snmp* -y 
yum install 'perl(Net::SNMP)' -y

cd /tmp
git clone https://github.com/SteScho/manubulon-snmp.git
cd manubulon-snmp/plugins/
chmod 777 *
