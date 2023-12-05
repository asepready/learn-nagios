#I. Requirements
#1) The SNMP manager can access the SNMP agent on switch by applying user-based security model. The user name is "admin", authentication mode is MD5, authentication key is "ruijie", encryption algorithm is DES56, and the encryption key is "123"
#2) User "admin" can read the MIB objects under System (1.3.6.1.2.1.1) node, and can only write MIB objects under SysContact (1.3.6.1.2.1.1.4.0) node.
#3) The switch can actively send authentication and encryption messages to the SNMP manager  

#III. Configuration Tips
#1. Create MIB view and specify the included or excluded MIB objects.  
#2. Create SNMP group and set the version to "v3"; specify the security level of this group, and configure the read-write permission of the view corresponding to this group.
#3. Create user name and associate the corresponding SNMP group name in order to further configure the user's permission to access MIB objects; meanwhile, configure the version number to "v3" and the corresponding authentication mode, authentication key, encryption algorithm and encryption key.  
#4. Configure the address of SNMP manager, configure the version "3" and configure the security level to be adopted.  
#IV. Configuration Steps
# Configuring switch：
Ruijie#configure terminal
Ruijie(config)#snmp-server view view1 1.3.6.1.2.1.1 include               # Create a MIB view of "view1" and include the MIB object of 1.3.6.1.2.1.1
Ruijie(config)#snmp-server view view2 1.3.6.1.2.1.1.4.0 include           # Create a MIB view of "view2" and include the MIB object of 1.3.6.1.2.1.1.4.0
Ruijie(config)#snmp-server group group1 v3 priv read view1 write view2    # Create a group named "g1" ,using SNMPv3 ; configure security level to "priv" ,and can read "view1"  and write "view2"
Ruijie(config)#snmp-server user admin group1 v3 auth md5 ruijie priv des56 ruijie123  # Create a user named "admin", which belongs to group "group1"; using SNMPv3 and authentication mode is "md5", authentication key is "ruijie", encryption mode is "DES56" and encryption key is "123".
Ruijie(config)#snmp-server host 192.168.1.2 traps version 3 priv admin     # Configure the SNMP server address as 192.168.1.2 , using SNMPv3,then configure security level to "priv" and associate the corresponding user name of "admin"
Ruijie(config)#snmp-server enable traps                                    # Enable the Agent to actively send traps to NMS
Ruijie(config)#interface vlan 1
Ruijie(config-if-VLAN 1)#ip address 192.168.1.1 255.255.255.0
Ruijie(config-if-VLAN 1)#end
# Set SNMP optional parameters
Ruijie(config)#snmp-server location fuzhou  
Ruijie(config)#snmp-server contact ruijie.com.cn         
Ruijie(config)#snmp-server chassis-id 1234567890
# Note： If you don't create a new SNMP view, Ruijie switch uses the default SNMP view named "default" ,including MIB object of 1
# Minimun SNMPv3 configuration example:
# snmp-server group group1 v3 priv read default write default   
# snmp-server user admin group1 v3 auth md5 ruijie priv des56 ruijie123   
# snmp-server host 192.168.1.2 traps version 3 priv admin   
# snmp-server enable traps   
# V. Verification
# 1. This example shows how to verify SNMP agent status
Ruijie(config)#show service
# Following example provides how to disable SNMP agent if snmp agent issue leads to heavy load of CPU :
Ruijie(config)#no enable service snmp-agent
#2. Following examples show how to display snmp view, snmp group and snmp user individually
Ruijie(config)#show snmp view
Ruijie(config)#show snmp group
Ruijie(config)#show snmp user