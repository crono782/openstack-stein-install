#!/bin/bash

# create database

./dbcreate.sh barbican barbican password

# create user, service, roles, endpoints

source ~/adminrc

openstack user create --domain default --password password barbican

openstack role add --project service --user barbican admin

openstack role create creator

openstack role add --project service --user barbican creator

openstack service create --name barbican --description "Key Manager" key-manager

./endpoint.sh key-manager 9311

# install packages

yum -y install openstack-barbican-api python2-barbicanclient

# configure barbican

./bak.sh /etc/barbican/barbican.conf

./conf.sh /etc/barbican/barbican.conf DEFAULT sql_connection mysql+pymysql://barbican:password@controller/barbican
./conf.sh /etc/barbican/barbican.conf DEFAULT transport_url rabbit://openstack:password@controller
./conf.sh /etc/barbican/barbican.conf DEFAULT db_auto_create False
./conf.sh /etc/barbican/barbican.conf DEFAULT host_href http://controller:9311
./conf.sh /etc/barbican/barbican.conf keystone_authtoken www_authenticate_uri http://controller:5000
./conf.sh /etc/barbican/barbican.conf keystone_authtoken auth_url http://controller:5000
./conf.sh /etc/barbican/barbican.conf keystone_authtoken memcached_servers controller:11211
./conf.sh /etc/barbican/barbican.conf keystone_authtoken auth_type password
./conf.sh /etc/barbican/barbican.conf keystone_authtoken project_domain_name default
./conf.sh /etc/barbican/barbican.conf keystone_authtoken user_domain_name default
./conf.sh /etc/barbican/barbican.conf keystone_authtoken project_name service
./conf.sh /etc/barbican/barbican.conf keystone_authtoken username barbican
./conf.sh /etc/barbican/barbican.conf keystone_authtoken password password
./conf.sh /etc/barbican/barbican.conf secretstore namespace barbican.secretstore.plugin
./conf.sh /etc/barbican/barbican.conf secretstore enabled_secretstore_plugins store_crypto
./conf.sh /etc/barbican/barbican.conf crypto namespace barbican.crypto.plugin
./conf.sh /etc/barbican/barbican.conf crypto enabled_crypto_plugins simple_crypto

# generate a new 32 byte kek value from https://generate.plus/en/base64

./conf.sh /etc/barbican/barbican.conf simple_crypto_plugin kek "'AmvyUmaU6oYPhFDDKOMjlyzXmumVFa6833wBgTcGxak='"

# load database

su -s /bin/sh -c "barbican-manage db upgrade" barbican

# start services

for i in enable start;do systemctl $i openstack-barbican-api;done

# verification

openstack secret store --name mysecret --payload j4=]d21

secrethref=$(openstack secret list --name mysecret -c 'Secret href' -f value)

openstack secret get $secrethref

openstack secret get $secrethref --payload

openstack secret delete $secrethref

unset secrethref

exit
