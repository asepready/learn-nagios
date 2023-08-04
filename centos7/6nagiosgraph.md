```sh
# https://sysadminote.com/how-to-install-nagiosgraph-to-display-graphs-in-nagios/
# Install the required packages
yum install -y rrdtool perl-Time-HiRes php-gd php-xml perl-CPAN rrdtool-perl perl-CGI-*

cd /tmp
wget http://downloads.sourceforge.net/project/nagiosgraph/nagiosgraph/1.5.2/nagiosgraph-1.5.2.tar.gz
tar -xf nagiosgraph-1.5.2.tar.gz
cd nagiosgraph-1.5.2

# Configure Nagiosgraph
mkdir /usr/local/nagios/nagiosgraph
mkdir /usr/local/nagios/nagiosgraph/var
mkdir /usr/local/nagios/nagiosgraph/var/rrd
 
cp -r etc /usr/local/nagios/nagiosgraph/
sed -i "s#/opt/nagiosgraph/etc#/usr/local/nagios/nagiosgraph/etc#g" cgi/*cgi
sed -i "s#/opt/nagiosgraph/etc#/usr/local/nagios/nagiosgraph/etc#g" lib/insert.pl

cp lib/insert.pl /usr/local/nagios/libexec
cp cgi/*.cgi /usr/local/nagios/sbin
cp share/nagiosgraph.css /usr/local/nagios/share
cp share/nagiosgraph.js /usr/local/nagios/share
cp /usr/local/nagios/nagiosgraph/etc/nagiosgraph.conf /usr/local/nagios/nagiosgraph/etc/nagiosgraph.conf.ori
cp /usr/local/nagios/etc/nagios.cfg /usr/local/nagios/etc/nagios.cfg.bkp

# vi share/nagiosgraph.ssi
<script type="text/javascript" src="/nagios/nagiosgraph.js"></script>

cp share/nagiosgraph.ssi /usr/local/nagios/share/ssi/common-header.ssi
chown nagios:nagios /usr/local/nagios/share/ssi/common-header.ssi

# change and edit vi /usr/local/nagios/nagiosgraph/etc/nagiosgraph.conf
#------ #!/usr/local/nagios/nagiosgraph/etc/nagiosgraph.conf -------
# Location of output from nagiosgraph data processing
logfile = /usr/local/nagios/nagiosgraph/var/nagiosgraph.log

# Location of output from nagiosgraph CGI scripts
cgilogfile = /usr/local/nagios/nagiosgraph/var/nagiosgraph-cgi.log

# Location of nagios performance data log file.
perflog = /usr/local/nagios/var/perfdata.log

# Directory in which to store RRD files
rrddir = /usr/local/nagios/nagiosgraph/var/rrd

# File containing regular expressions to identify service and perf data
mapfile = /usr/local/nagios/nagiosgraph/etc/map

# Nagiosgraph CGI URL.
nagiosgraphcgiurl = /nagios/cgi-bin

# JavaScript: URL to the nagiosgraph javascript file.
javascript = /nagios/nagiosgraph.js

# Stylesheet: URL to the nagiosgraph stylesheet.
stylesheet = /nagios/nagiosgraph.css

# Location of showgroup control file (required for showgroup.cgi)
groupdb = /usr/local/nagios/nagiosgraph/etc/groupdb.conf
#----------------------------------------------------------------------------------

chown -R nagios:nagcmd /usr/local/nagios/nagiosgraph
chmod 755 /usr/local/nagios/nagiosgraph/var/rrd
touch /usr/local/nagios/nagiosgraph/var/nagiosgraph.log
chmod 664 /usr/local/nagios/nagiosgraph/var/nagiosgraph.log
touch /usr/local/nagios/nagiosgraph/var/nagiosgraph-cgi.log
chown apache /usr/local/nagios/nagiosgraph/var/nagiosgraph-cgi.log
chmod 664 /usr/local/nagios/nagiosgraph/var/nagiosgraph-cgi.log

# Configure Nagios vi /usr/local/nagios/etc/nagios.cfg
process_performance_data=1
service_perfdata_file=/usr/local/nagios/var/perfdata.log
service_perfdata_file_template=$LASTSERVICECHECK$||$HOSTNAME$||$SERVICEDESC$||$SERVICEOUTPUT$||$SERVICEPERFDATA$ 
service_perfdata_file_mode=a
service_perfdata_file_processing_interval=30
service_perfdata_file_processing_command=process-service-perfdata

# copi icon
cp -f share/graph.gif /usr/local/nagios/share/images/action.gif

# vi /usr/local/nagios/share/side.php
<li><a href="<?php echo $cfg["cgi_base_url"];?>/trends.cgi" target="<?php echo $link_target;?>">Trends</a>
    <ul>
        <li><a href="<?php echo $cfg["cgi_base_url"];?>/show.cgi" target="<?php echo $link_target;?>">Graphs</a></li>
        <li><a href="<?php echo $cfg["cgi_base_url"];?>/showhost.cgi" target="<?php echo $link_target;?>">Graphs by Host</a></li>
        <li><a href="<?php echo $cfg["cgi_base_url"];?>/showservice.cgi" target="<?php echo $link_target;?>">Graphs by Service</a></li>
        <li><a href="<?php echo $cfg["cgi_base_url"];?>/showgroup.cgi" target="<?php echo $link_target;?>">Graphs by Group</a></li>
    </ul>
</li>

# Integrate Nagios with Nagiosgraph
# Configure the commands.cfg file vi /usr/local/nagios/etc/objects/commands.cfg
echo '' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'define command {' >> /usr/local/nagios/etc/objects/commands.cfg
echo '    command_name  process-service-perfdata' >> /usr/local/nagios/etc/objects/commands.cfg
echo '    command_line  /usr/local/nagios/libexec/insert.pl' >> /usr/local/nagios/etc/objects/commands.cfg
echo '}' >> /usr/local/nagios/etc/objects/commands.cfg

# Configure templates.cfg file vi /usr/local/nagios/etc/objects/templates.cfg
echo '' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'define service {' >> /usr/local/nagios/etc/objects/templates.cfg
echo '        name graphed-service' >> /usr/local/nagios/etc/objects/templates.cfg
echo '        max_check_attempts              4  ; Re-check the service up to 4 times in order to determine its final (hard)state' >> /usr/local/nagios/etc/objects/templates.cfg
echo '        check_interval                  5  ; Check the service every 5 minutes under normal conditions' >> /usr/local/nagios/etc/objects/templates.cfg
echo '        retry_interval                  1  ; Re-check the service every minute until a hard state can be determined' >> /usr/local/nagios/etc/objects/templates.cfg
echo '        register                        0  ; DONT REGISTER THIS DEFINITION - ITS NOT A REAL SERVICE, JUST A TEMPLATE!' >> /usr/local/nagios/etc/objects/templates.cfg
echo '        action_url                      /nagios/cgi-bin/show.cgi?host=$HOSTNAME$&service=$SERVICEDESC$' onMouseOver='showGraphPopup(this)' onMouseOut='hideGraphPopup()' rel='/nagios/cgi-bin/showgraph.cgi?host=$HOSTNAME$&service=$SERVICEDESC$&period=week&rrdopts=-w+450+-j' >> /usr/local/nagios/etc/objects/templates.cfg
echo '}' >> /usr/local/nagios/etc/objects/templates.cfg

# Configure localhost.cfg file vi /usr/local/nagios/etc/objects/localhost.cfg
sed -i 's/    use                     local-service/    use                     local-service,graphed-service/g' /usr/local/nagios/etc/objects/localhost.cfg