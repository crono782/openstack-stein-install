#!/bin/bash

# install packages

yum -y install openstack-manila-share python2-PyMySQL

# conf file work

./bak.sh /etc/manila/manila.conf

./conf.sh /etc/manila/manila.conf database connection mysql+pymysql://manila:password@controller/manila
./conf.sh /etc/manila/manila.conf DEFAULT transport_url rabbit://openstack:password@controller
./conf.sh /etc/manila/manila.conf DEFAULT default_share_type default_share_type
./conf.sh /etc/manila/manila.conf DEFAULT rootwrap_config /etc/manila/rootwrap.conf
./conf.sh /etc/manila/manila.conf DEFAULT auth_strategy = keystone
./conf.sh /etc/manila/manila.conf DEFAULT my_ip 10.10.10.57
./conf.sh /etc/manila/manila.conf keystone_authtoken memcached_servers controller:11211
./conf.sh /etc/manila/manila.conf keystone_authtoken www_authenticate_uri http://controller:5000
./conf.sh /etc/manila/manila.conf keystone_authtoken auth_url http://controller:5000
./conf.sh /etc/manila/manila.conf keystone_authtoken auth_type password
./conf.sh /etc/manila/manila.conf keystone_authtoken project_domain_name Default
./conf.sh /etc/manila/manila.conf keystone_authtoken user_domain_name Default
./conf.sh /etc/manila/manila.conf keystone_authtoken project_name service
./conf.sh /etc/manila/manila.conf keystone_authtoken username manila
./conf.sh /etc/manila/manila.conf keystone_authtoken password password
./conf.sh /etc/manila/manila.conf oslo_concurrency lock_path /var/lib/manila/tmp

exit
