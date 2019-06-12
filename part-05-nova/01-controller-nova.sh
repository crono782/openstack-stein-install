#!/bin/bash

# create nova databases

./dbcreate.sh nova_api nova password
./dbcreate.sh nova nova password
./dbcreate.sh nova_cell0 nova password

# create user, add role, create service and endpoints

source ~/adminrc

openstack user create --domain default --password password nova

openstack role add --project service --user nova admin

openstack service create --name nova --description "OpenStack Compute" compute

./endpoint.sh compute 8774/v2.1

# install packages

yum -y install openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler

# conf file work

./bak.sh /etc/nova/nova.conf

./conf.sh /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
./conf.sh /etc/nova/nova.conf DEFAULT my_ip 10.10.10.51
./conf.sh /etc/nova/nova.conf DEFAULT use_neutron true
./conf.sh /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
./conf.sh /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:password@controller
./conf.sh /etc/nova/nova.conf api auth_strategy keystone
./conf.sh /etc/nova/nova.conf api_database connection mysql+pymysql://nova:password@controller/nova_api
./conf.sh /etc/nova/nova.conf database connection mysql+pymysql://nova:password@controller/nova
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
# single quote '$my_ip' so bash doesn't try to interpret it
./conf.sh /etc/nova/nova.conf vnc server_listen '$my_ip'
./conf.sh /etc/nova/nova.conf vnc server_proxyclient_address '$my_ip'

# sync/build databases and start services

su -s /bin/sh -c "nova-manage api_db sync" nova

su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova

su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova

su -s /bin/sh -c "nova-manage db sync" nova

su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova

for i in enable start;do systemctl $i openstack-nova-{api,scheduler,conductor,novncproxy};done

exit
