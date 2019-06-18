#!/bin/bash
#################
# controller node
#################

# some verification
openstack dns service list

# install ui

yum -y install openstack-designate-ui

systemctl restart httpd

# create a blacklist perhaps

source ~/adminrc

openstack zone blacklist create --pattern '^.(?!.*\.cloud\.learnoss\.com\.$)' 
openstack zone create --email root@learnoss.com test.cloud.learnoss.com.
openstack zone list
openstack recordset create --type A --record 192.168.0.100 test.cloud.learnoss.com. www
openstack recordset list test.cloud.learnoss.com.
openstack recordset delete www.test.cloud.learnoss.com.
openstack zone delete test.cloud.learnoss.com.
