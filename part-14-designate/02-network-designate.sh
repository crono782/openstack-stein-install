#!/bin/bash
##############
# network node 
##############

yum -y install openstack-designate-mdns openstack-designate-producer openstack-designate-worker

# configure designate

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

# configure bind and rndc

yum -y install bind bind-utils

rndc-confgen -a -k designate -c /etc/designate/rndc.key -r /dev/urandom
chown named:designate /etc/designate/rndc.key

sed -i -e 's/listen-on port 53 {.*/listen-on-port 53 { any; };/'\
 -e 's/listen-on-v6 port 53 {.*/listen-on-v6 port 53 { none; };/'\
 -e 's/allow-query {.*/allow-query { any; };/'\
 -e 's/recursion yes/recursion no/' /etc/named.conf
sed -i -e '/^options {/a allow-new-zones yes;'\
 -e '/^options {/a request-ixfr no;' /etc/named.conf

acl "mdns-server" {
  127.0.0.1;
};
include "/etc/designate/rndc.key";
controls {
  inet 127.0.0.1 port 953 allow {"mdns-server";} keys {"designate";};
};

# start bind
for i in enable start;do systemctl $i named;done

# create pools.yaml
cat <<EOF > /etc/designate/pools.yaml
- name: default
  description: Default Pool
  attributes: {}
  ns_records:
    - hostname: network.
      priority: 1
  nameservers:
    - host: 127.0.0.1
      port: 53
  targets:
    - type: bind9
      description: BIND9 Server 1
      masters:
        - host: 127.0.0.1
          port: 5354
      options:
        host: 127.0.0.1
        port: 53
        rndc_host: 127.0.0.1
        rndc_port: 953
        rndc_key_file: /etc/designate/rndc.key
EOF

# update pools db

su -s /bin/sh -c "designate-manage pool update" designate

# start remaining designate services

for i in enable start;do systemctl $i designate-{producer,worker,mdns};done
