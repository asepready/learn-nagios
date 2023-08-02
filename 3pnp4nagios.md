```sh
# Prerequisites
yum install -y rrdtool perl-rrdtool perl-Time-HiRes php-gd

# Downloading the Source
cd /tmp
wget -O pnp4nagios.tar.gz https://github.com/lingej/pnp4nagios/archive/refs/tags/0.6.26.tar.gz
tar xzf pnp4nagios.tar.gz

# Compile & Install
cd pnp4nagios-0.6.26
./configure --with-rrdtool=/usr/bin/rrdtool --with-nagios-user=nagios --with-nagios-group=nagios
make all
make install
make install-webconf
make install-config
make install-init
 
# Configure & Start Service / Daemon
systemctl daemon-reload
systemctl enable npcd.service
systemctl start npcd.service
systemctl restart httpd.service

# Update Nagios
sed -i 's/process_performance_data=0/process_performance_data=1/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/enable_environment_macros=0/enable_environment_macros=1/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/#host_perfdata_file=/host_perfdata_file=/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/^host_perfdata_file=.*/host_perfdata_file=\/usr\/local\/pnp4nagios\/var\/service-perfdata/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/^#host_perfdata_file_template=.*/host_perfdata_file_template=DATATYPE::HOSTPERFDATA\\tTIMET::$TIMET$\\tHOSTNAME::$HOSTNAME$\\tHOSTPERFDATA::$HOSTPERFDATA$\\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\\tHOSTSTATE::$HOSTSTATE$\\tHOSTSTATETYPE::$HOSTSTATETYPE$/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/#host_perfdata_file_mode=/host_perfdata_file_mode=/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/^#host_perfdata_file_processing_interval=.*/host_perfdata_file_processing_interval=15/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/^#host_perfdata_file_processing_command=.*/host_perfdata_file_processing_command=process-host-perfdata-file-bulk-npcd/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/#service_perfdata_file=/service_perfdata_file=/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/^service_perfdata_file=.*/service_perfdata_file=\/usr\/local\/pnp4nagios\/var\/service-perfdata/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_file_template=.*/service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\\tTIMET::$TIMET$\\tHOSTNAME::$HOSTNAME$\\tSERVICEDESC::$SERVICEDESC$\\tSERVICEPERFDATA::$SERVICEPERFDATA$\\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\\tHOSTSTATE::$HOSTSTATE$\\tHOSTSTATETYPE::$HOSTSTATETYPE$\\tSERVICESTATE::$SERVICESTATE$\\tSERVICESTATETYPE::$SERVICESTATETYPE$/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/#service_perfdata_file_mode=/service_perfdata_file_mode=/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_file_processing_interval=.*/service_perfdata_file_processing_interval=15/g' /usr/local/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_file_processing_command=.*/service_perfdata_file_processing_command=process-service-perfdata-file-bulk-npcd/g' /usr/local/nagios/etc/nagios.cfg

# Update Command
echo '' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'define command {' >> /usr/local/nagios/etc/objects/commands.cfg
echo '    command_name    process-host-perfdata-file-bulk-npcd' >> /usr/local/nagios/etc/objects/commands.cfg
echo '    command_line    /bin/mv /usr/local/pnp4nagios/var/host-perfdata /usr/local/pnp4nagios/var/spool/host-perfdata.$TIMET$' >> /usr/local/nagios/etc/objects/commands.cfg
echo '}' >> /usr/local/nagios/etc/objects/commands.cfg
echo '' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'define command {' >> /usr/local/nagios/etc/objects/commands.cfg
echo '    command_name    process-service-perfdata-file-bulk-npcd' >> /usr/local/nagios/etc/objects/commands.cfg
echo '    command_line    /bin/mv /usr/local/pnp4nagios/var/service-perfdata /usr/local/pnp4nagios/var/spool/service-perfdata.$TIMET$' >> /usr/local/nagios/etc/objects/commands.cfg
echo '}' >> /usr/local/nagios/etc/objects/commands.cfg
echo '' >> /usr/local/nagios/etc/objects/commands.cfg

# Verifi update Nagios
verifynagios

# Reboot Nagios
systemctl restart nagios.service
systemctl restart httpd

# Verify PNP4Nagios Is Working
ls -la /usr/local/pnp4nagios/var/perfdata/localhost/

# To remove the install.php file execute the following command:
rm -f /usr/local/pnp4nagios/share/install.php

# Nagios Core Web Interface Integration
# Update template.cfg
echo '' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'define host {' >> /usr/local/nagios/etc/objects/templates.cfg
echo '   name       host-pnp' >> /usr/local/nagios/etc/objects/templates.cfg
echo '   action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=_HOST_' >> /usr/local/nagios/etc/objects/templates.cfg
echo '   register   0' >> /usr/local/nagios/etc/objects/templates.cfg
echo '}' >> /usr/local/nagios/etc/objects/templates.cfg
echo '' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'define service {' >> /usr/local/nagios/etc/objects/templates.cfg
echo '   name       service-pnp' >> /usr/local/nagios/etc/objects/templates.cfg
echo '   action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$' >> /usr/local/nagios/etc/objects/templates.cfg
echo '   register   0' >> /usr/local/nagios/etc/objects/templates.cfg
echo '}' >> /usr/local/nagios/etc/objects/templates.cfg
echo '' >> /usr/local/nagios/etc/objects/templates.cfg

# Update template.cfg
sed -i '/name.*generic-host/a\        use                             host-pnp' /usr/local/nagios/etc/objects/templates.cfg
sed -i '/name.*generic-service/a\        use                             service-pnp' /usr/local/nagios/etc/objects/templates.cfg

################################################################################
# Solution
nano /usr/local/pnp4nagios/share/application/models/data.php

# Default line number: 979
Change from
if(sizeof($pages) > 0 ){

To
/*if(sizeof($pages) > 0 ){*/
   if(is_array($pages)&&sizeof($pages) > 0){

### Solution
nano /usr/local/pnp4nagios/share/application/lib/json.php

From
class Services_JSON
To
class _Services_JSON

From
class Services_JSON_Error extends PEAR_Error
To
class _Services_JSON_Error extends PEAR_Error

From
class Services_JSON_Error
To
class _Services_JSON_Error

# Restart Nagios
cd /tmp/pnp4nagios-0.6.26/scripts
./verify_pnp_config_v2.pl -m bulk -c /usr/local/nagios/etc/nagios.cfg -p /usr/local/pnp4nagios/etc/

systemctl restart nagios.service

