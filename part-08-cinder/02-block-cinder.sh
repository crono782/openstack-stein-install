#!/bin/bash

# make sure packages are installed

yum -y install lvm2 device-mapper-persistent-data

# make sure services are enabled and started

for i in enable start; do systemctl $i lvm2-lvmetad;done

# create LVM PVs

pvcreate /dev/vd{b,c,d,e}

# create VG to simulate SSD storage

vgcreate cindervols-ssd /dev/vd{b,c}

# create VG to simulate HDD storage

vgcreate cindervols-hdd /dev/vd{d,e}

# apply device filters to LVM

l=$(sed -n '/# filter = /=' /etc/lvm/lvm.conf|tail -n1);sed -i "${l}a filter = [ 'a|vda|','a|vdb|','a|vdc|','a|vdd|','a|vde|','r|.*|' ]" /etc/lvm/lvm.conf

# install packages

yum -y install openstack-cinder targetcli python-keystone

# conf file work

./bak.sh /etc/cinder/cinder.conf

./conf.sh /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:password@controller/cinder
./conf.sh /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:password@controller
./conf.sh /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
./conf.sh /etc/cinder/cinder.conf DEFAULT my_ip 10.10.10.54
./conf.sh /etc/cinder/cinder.conf DEFAULT enabled_backends lvm-ssd,lvm-hdd
./conf.sh /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
./conf.sh /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000
./conf.sh /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000
./conf.sh /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
./conf.sh /etc/cinder/cinder.conf keystone_authtoken auth_type password
./conf.sh /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
./conf.sh /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
./conf.sh /etc/cinder/cinder.conf keystone_authtoken project_name service
./conf.sh /etc/cinder/cinder.conf keystone_authtoken username cinder
./conf.sh /etc/cinder/cinder.conf keystone_authtoken password password
./conf.sh /etc/cinder/cinder.conf backend_default volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
./conf.sh /etc/cinder/cinder.conf backend_default target_protocol iscsi
./conf.sh /etc/cinder/cinder.conf backend_default target_helper lioadm
./conf.sh /etc/cinder/cinder.conf lvm-ssd volume_group cindervols-ssd
./conf.sh /etc/cinder/cinder.conf lvm-ssd volume_backend_name LVM-SSD
./conf.sh /etc/cinder/cinder.conf lvm-hdd volume_group cindervols-hdd
./conf.sh /etc/cinder/cinder.conf lvm-hdd volume_backend_name LVM-HDD
./conf.sh /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

# enable and start services
for i in enable start;do systemctl $i openstack-cinder-volume target;done

exit
