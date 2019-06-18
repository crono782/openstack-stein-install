#!/bin/bash

: << END
locating api and central services on controller node,
producer, worker, and mdns on network or dns node
you could make the dns node also host the bind service
or host it externally (production)
for a private org, you could make the dns sever recursive
and use whitelist (negative blacklist) entries to put up
boundaries for tenants. (e.g. '^.(?!.*\.cloud\.learnoss\.com\.$)')
if this was a public cloud, leave it authoritative only
END

#################
# controller node
#################

source ~/adminrc

openstack user create --domain default --password password designate

openstack role add --project service --user designate admin

openstack service create --name designate --description "DNS" dns

# puts api on controller
./endpoint.sh dns 9001

yum -y install openstack-designate-api openstack-designate-central

./dbcreate.sh designate designate password

./bak.sh /etc/designate/designate.conf

./conf.sh /etc/designate/designate.conf service:api listen 0.0.0.0:9001
./conf.sh /etc/designate/designate.conf service:api auth_strategy keystone
./conf.sh /etc/designate/designate.conf service:api api_base_uri http://controller:9001/
./conf.sh /etc/designate/designate.conf service:api enable_api_v2 True
./conf.sh /etc/designate/designate.conf service:api enabled_extensions_v2 quotas, reports
./conf.sh /etc/designate/designate.conf keystone_authtoken auth_type password
./conf.sh /etc/designate/designate.conf keystone_authtoken username designate
./conf.sh /etc/designate/designate.conf keystone_authtoken password password
./conf.sh /etc/designate/designate.conf keystone_authtoken project_name service
./conf.sh /etc/designate/designate.conf keystone_authtoken project_domain_name Default
./conf.sh /etc/designate/designate.conf keystone_authtoken user_domain_name Default
./conf.sh /etc/designate/designate.conf keystone_authtoken www_authenticate_uri http://controller:5000/
./conf.sh /etc/designate/designate.conf keystone_authtoken auth_url http://controller:5000/
./conf.sh /etc/designate/designate.conf service:worker enabled True
./conf.sh /etc/designate/designate.conf service:worker notify True
./conf.sh /etc/designate/designate.conf storage:sqlalchemy connection mysql+pymysql://designate:password@controller/designate

su -s /bin/sh -c "designate-manage database sync" designate

for i in enable start;do systemctl $i designate-{api,central};done
