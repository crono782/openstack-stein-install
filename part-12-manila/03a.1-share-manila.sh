#!/bin/bash

# install packages

yum -y install lvm2 nfs-utils nfs4-acl-tools portmap targetcli

# start core services

for i in enable start;do systemctl $i lvm2-lvmetad target;done

pvcreate /dev/vd{b,c}

vgcreate manila-volumes /dev/vd{b,c}

# reconfig lvm.conf

l=$(sed -n '/# filter = /=' /etc/lvm/lvm.conf|tail -n1);sed -i "${l}a filter = [ 'a|vda|','a|vdb|','a|vdc|','r|.*|' ]" /etc/lvm/lvm.conf

# conf file work

./conf.sh /etc/manila/manila.conf DEFAULT enabled_share_backends lvm
./conf.sh /etc/manila/manila.conf DEFAULT enabled_share_protocols NFS
./conf.sh /etc/manila/manila.conf lvm share_backend_name LVM
./conf.sh /etc/manila/manila.conf lvm share_driver manila.share.drivers.lvm.LVMShareDriver
./conf.sh /etc/manila/manila.conf lvm driver_handles_share_servers False
./conf.sh /etc/manila/manila.conf lvm lvm_share_volume_group manila-volumes
./conf.sh /etc/manila/manila.conf lvm lvm_share_export_ip 172.6.0.3

# ensure system dirs created correctly

mkdir /var/lib/manila
chown manila:manila /var/lib/manila

# start service

for i in enable start;do systemctl $i nfs-server openstack-manila-share;done

exit
