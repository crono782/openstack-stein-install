#!/bin/bash

# verification

source ~/adminrc

manila service-list

# install manila dashbard packages

yum -y install openstack-manila-ui

systemctl restart httpd

exit
