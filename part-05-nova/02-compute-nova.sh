#!/bin/bash

# install packages

yum -y install openstack-nova-compute

# conf file work

./bak.sh /etc/nova/nova.conf

./conf.sh /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
./conf.sh /etc/nova/nova.conf DEFAULT my_ip 10.10.10.52
./conf.sh /etc/nova/nova.conf DEFAULT use_neutron true
./conf.sh /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
./conf.sh /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:password@controller
./conf.sh /etc/nova/nova.conf api auth_strategy keystone
./conf.sh /etc/nova/nova.conf glance api_servers http://controller:9292
./conf.sh /etc/nova/nova.conf keystone_authtoken auth_url http://controller:5000/v3
./conf.sh /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
./conf.sh /etc/nova/nova.conf keystone_authtoken auth_type password
./conf.sh /etc/nova/nova.conf keystone_authtoken project_domain_name Default
./conf.sh /etc/nova/nova.conf keystone_authtoken user_domain_name Default
./conf.sh /etc/nova/nova.conf keystone_authtoken project_name service
./conf.sh /etc/nova/nova.conf keystone_authtoken username nova
./conf.sh /etc/nova/nova.conf keystone_authtoken password password
./conf.sh /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
./conf.sh /etc/nova/nova.conf placement region_name RegionOne
./conf.sh /etc/nova/nova.conf placement project_domain_name Default
./conf.sh /etc/nova/nova.conf placement project_name service
./conf.sh /etc/nova/nova.conf placement auth_type password
./conf.sh /etc/nova/nova.conf placement user_domain_name Default
./conf.sh /etc/nova/nova.conf placement auth_url http://controller:5000/v3
./conf.sh /etc/nova/nova.conf placement username placement
./conf.sh /etc/nova/nova.conf placement password password
./conf.sh /etc/nova/nova.conf vnc enabled true
./conf.sh /etc/nova/nova.conf vnc server_listen 0.0.0.0
# single quote '$my_ip' so bash doesn't try to interpret it
./conf.sh /etc/nova/nova.conf vnc server_proxyclient_address '$my_ip'
./conf.sh /etc/nova/nova.conf vnc novncproxy_base_url http://controller:6080/vnc_auto.html

# start services

for i in enable start;do systemctl $i libvirtd openstack-nova-compute;done

exit
