#!/bin/bash

# install packages

yum -y install openstack-neutron openstack-neutron-openvswitch libibverbs ebtables

# conf file work

./conf.sh /etc/manila/manila.conf DEFAULT enabled_share_backends generic
./conf.sh /etc/manila/manila.conf DEFAULT enabled_share_protocols NFS
./conf.sh /etc/manila/manila.conf neutron url http://controller:9696
./conf.sh /etc/manila/manila.conf neutron www_authenticate_uri http://controller:5000
./conf.sh /etc/manila/manila.conf neutron auth_url http://controller:5000
./conf.sh /etc/manila/manila.conf neutron memcached_servers controller:11211
./conf.sh /etc/manila/manila.conf neutron auth_type password
./conf.sh /etc/manila/manila.conf neutron project_domain_name Default
./conf.sh /etc/manila/manila.conf neutron user_domain_name Default
./conf.sh /etc/manila/manila.conf neutron region_name RegionOne
./conf.sh /etc/manila/manila.conf neutron project_name service
./conf.sh /etc/manila/manila.conf neutron username neutron
./conf.sh /etc/manila/manila.conf neutron password password
./conf.sh /etc/manila/manila.conf nova www_authenticate_uri http://controller:5000
./conf.sh /etc/manila/manila.conf nova auth_url http://controller:5000
./conf.sh /etc/manila/manila.conf nova memcached_servers controller:11211
./conf.sh /etc/manila/manila.conf nova auth_type password
./conf.sh /etc/manila/manila.conf nova project_domain_name Default
./conf.sh /etc/manila/manila.conf nova user_domain_name Default
./conf.sh /etc/manila/manila.conf nova region_name RegionOne
./conf.sh /etc/manila/manila.conf nova project_name service
./conf.sh /etc/manila/manila.conf nova username nova
./conf.sh /etc/manila/manila.conf nova password password
./conf.sh /etc/manila/manila.conf cinder www_authenticate_uri http://controller:5000
./conf.sh /etc/manila/manila.conf cinder auth_url http://controller:5000
./conf.sh /etc/manila/manila.conf cinder memcached_servers controller:11211
./conf.sh /etc/manila/manila.conf cinder auth_type password
./conf.sh /etc/manila/manila.conf cinder project_domain_name Default
./conf.sh /etc/manila/manila.conf cinder user_domain_name Default
./conf.sh /etc/manila/manila.conf cinder region_name RegionOne
./conf.sh /etc/manila/manila.conf cinder project_name service
./conf.sh /etc/manila/manila.conf cinder username cinder
./conf.sh /etc/manila/manila.conf cinder password password
./conf.sh /etc/manila/manila.conf generic share_backend_name GENERIC
./conf.sh /etc/manila/manila.conf generic share_driver manila.share.drivers.generic.GenericShareDriver
./conf.sh /etc/manila/manila.conf generic driver_handles_share_servers True
./conf.sh /etc/manila/manila.conf generic service_instance_flavor_id 100
./conf.sh /etc/manila/manila.conf generic service_image_name manila-service-image
./conf.sh /etc/manila/manila.conf generic service_instance_user manila
./conf.sh /etc/manila/manila.conf generic service_instance_password manila
./conf.sh /etc/manila/manila.conf generic interface_driver manila.network.linux.interface.OVSInterfaceDriver

for i in enable start;do systemctl $i openvswitch neutron-openvswitch-agent openstack-manila-share;done

exit
