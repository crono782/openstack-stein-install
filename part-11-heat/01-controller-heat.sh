#!/bin/bash

# create database

./dbcreate.sh heat heat password

# create projects, users, roles, domains, endpoints, etc

source ~/adminrc

openstack user create --domain default --password password heat

openstack role add --project service --user heat admin

openstack service create --name heat --description "Orchestration" orchestration

openstack service create --name heat-cfn --description "Orchestration"  cloudformation

./endpoint.sh orchestration 8004/v1/%\(tenant_id\)s

./endpoint.sh cloudformation 8000/v1

openstack domain create --description "Stack projects and users" heat

openstack user create --domain heat --password password heat_domain_admin

openstack role add --domain heat --user-domain heat --user heat_domain_admin admin

openstack role create heat_stack_owner

openstack role add --project learnoss --user dqueen heat_stack_owner

openstack role create heat_stack_user

# install packages

yum -y install openstack-heat-api openstack-heat-api-cfn openstack-heat-engine

# conf file work

./bak.sh /etc/heat/heat.conf

./conf.sh /etc/heat/heat.conf database connection mysql+pymysql://heat:password@controller/heat
./conf.sh /etc/heat/heat.conf DEFAULT transport_url rabbit://openstack:password@controller
./conf.sh /etc/heat/heat.conf DEFAULT heat_metadata_server_url http://controller:8000
./conf.sh /etc/heat/heat.conf DEFAULT heat_waitcondition_server_url http://controller:8000/v1/waitcondition
./conf.sh /etc/heat/heat.conf DEFAULT stack_domain_admin heat_domain_admin
./conf.sh /etc/heat/heat.conf DEFAULT stack_domain_admin_password password
./conf.sh /etc/heat/heat.conf DEFAULT stack_user_domain_name heat
./conf.sh /etc/heat/heat.conf keystone_authtoken auth_uri http://controller:5000
./conf.sh /etc/heat/heat.conf keystone_authtoken auth_url http://controller:5000
./conf.sh /etc/heat/heat.conf keystone_authtoken memcached_servers controller:11211
./conf.sh /etc/heat/heat.conf keystone_authtoken auth_type password
./conf.sh /etc/heat/heat.conf keystone_authtoken project_domain_name default
./conf.sh /etc/heat/heat.conf keystone_authtoken user_domain_name default
./conf.sh /etc/heat/heat.conf keystone_authtoken project_name service
./conf.sh /etc/heat/heat.conf keystone_authtoken username heat
./conf.sh /etc/heat/heat.conf keystone_authtoken password password
./conf.sh /etc/heat/heat.conf trustee auth_type password
./conf.sh /etc/heat/heat.conf trustee auth_url http://controller:5000
./conf.sh /etc/heat/heat.conf trustee username heat
./conf.sh /etc/heat/heat.conf trustee password password
./conf.sh /etc/heat/heat.conf trustee user_domain_name default
./conf.sh /etc/heat/heat.conf clients_keystone auth_uri http://controller:5000

# populate database

su -s /bin/sh -c "heat-manage db_sync" heat

# enable and start services

for i in enable start;do systemctl $i openstack-heat-{api{,-cfn},engine};done

# verifications

source ~/adminrc

openstack orchestration service list

# install heat dashboard packages

yum -y install openstack-heat-ui

# reload apache

systemctl restart httpd

exit
