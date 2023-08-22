# Learn Network Monitoring
Simulation Network Monitoring using GNS3

- Nagios Core 4.4.14 and Nagios XI
- NagiosGrapher
- NDO 
- Nagvis

## Referensi Nagios
- [SteScho --> ](https://github.com/SteScho/manubulon-snmp)(https://github.com/SteScho/manubulon-snmp)
- [techarkit --> ](https://github.com/techarkit/nagios)(https://github.com/techarkit/nagios)
- [Nagios Plugins --> ](https://www.nagios.org/downloads/nagios-plugins/)(https://www.nagios.org/downloads/nagios-plugins/)
- [Nagios Frontend --> ](https://www.nagios.org/downloads/nagios-core-frontends/)(https://www.nagios.org/downloads/nagios-core-frontends/)
- [Nagios Addon Projects --> ](https://www.nagios.org/downloads/nagios-core-addons/)(https://www.nagios.org/downloads/nagios-core-addons/)


## Create VM
- Centos 7
```sh
# Create Image Disk
qemu-img create -f qcow2 \
/home/$USER/kvm/netmon.qcow2 \
128G

#
virt-install --name netmon \
  --virt-type kvm --memory 4096 --vcpus 8 \
  --boot hd,menu=on \
  --disk path=/home/$USER/kvm/netmon.qcow2,device=disk \
  --cdrom=/home/$USER/kvm/CentOS-7-x86_64-Everything-2009.iso \
  --graphics spice \
  --os-type Linux --os-variant centos7
#
qemu-img convert -c \
/home/$USER/kvm/centos7.qcow2 -O qcow2 \
/home/$USER/kvm/nagioscore.qcow2
```

- FreeBSD 11
```sh
# Create Image Disk
qemu-img create -f qcow2 \
/home/$USER/kvm/fbsd.qcow2 \
128G

# 
virt-install --name fbsd \
  --virt-type kvm --memory 4096 --vcpus 8 \
  --boot hd,menu=on \
  --disk path=/home/$USER/kvm/fbsd.qcow2,device=disk \
  --cdrom=/home/$USER/kvm/FreeBSD-12.4-STABLE-amd64-20230608-r373095-disc1.iso \
  --graphics spice \
  --os-type Linux --os-variant fbsd11.4

#
qemu-img convert -c \
/home/$USER/kvm/fbsd.qcow2 -O qcow2 \
/home/$USER/kvm/fnagios.qcow2
```