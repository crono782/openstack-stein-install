#!/bin/bash

# create glance database

./dbcreate.sh glance glance password

# create user, add role, create service, create endpoints

source ~/adminrc

openstack user create --domain default --password password glance

openstack role add --project service --user glance admin

openstack service create --name glance --description "OpenStack Image" image

./endpoint.sh image 9292

# install packages

yum -y install openstack-glance

# conf file work

./bak.sh /etc/glance/glance-api.conf

./conf.sh /etc/glance/glance-api.conf database connection mysql+pymysql://glance:password@controller/glance
./conf.sh /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri http://controller:5000
./conf.sh /etc/glance/glance-api.conf keystone_authtoken auth_url http://controller:5000
./conf.sh /etc/glance/glance-api.conf keystone_authtoken memcached_servers controller:11211
./conf.sh /etc/glance/glance-api.conf keystone_authtoken auth_type password
./conf.sh /etc/glance/glance-api.conf keystone_authtoken project_domain_name Default
./conf.sh /etc/glance/glance-api.conf keystone_authtoken user_domain_name Default
./conf.sh /etc/glance/glance-api.conf keystone_authtoken project_name service
./conf.sh /etc/glance/glance-api.conf keystone_authtoken username glance
./conf.sh /etc/glance/glance-api.conf keystone_authtoken password password
./conf.sh /etc/glance/glance-api.conf glance_store stores file,http
./conf.sh /etc/glance/glance-api.conf glance_store default_store file
./conf.sh /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/
./conf.sh /etc/glance/glance-api.conf paste_deploy flavor keystone

./bak.sh /etc/glance/glance-registry.conf

./conf.sh /etc/glance/glance-api.conf database connection mysql+pymysql://glance:password@controller/glance
./conf.sh /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri http://controller:5000
./conf.sh /etc/glance/glance-api.conf keystone_authtoken auth_url http://controller:5000
./conf.sh /etc/glance/glance-api.conf keystone_authtoken memcached_servers controller:11211
./conf.sh /etc/glance/glance-api.conf keystone_authtoken auth_type password
./conf.sh /etc/glance/glance-api.conf keystone_authtoken project_domain_name Default
./conf.sh /etc/glance/glance-api.conf keystone_authtoken user_domain_name Default
./conf.sh /etc/glance/glance-api.conf keystone_authtoken project_name service
./conf.sh /etc/glance/glance-api.conf keystone_authtoken username glance
./conf.sh /etc/glance/glance-api.conf keystone_authtoken password password
./conf.sh /etc/glance/glance-api.conf paste_deploy flavor keystone

# sync database and start services

su -s /bin/sh -c "glance-manage db_sync" glance

for i in enable start;do systemctl $i openstack-glance-{api,registry};done

# download cirros test image and upload to glance for verification

yum -y install wget

wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img

openstack image create "cirros" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public

rm -f cirros-0.4.0-x86_64-disk.img

exit
