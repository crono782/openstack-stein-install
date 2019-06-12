#!/bin/bash

# obtain and upload manila image (optionally, build a custom one with diskimage-builder)

wget http://tarballs.openstack.org/manila-image-elements/images/manila-service-image-master.qcow2

source adminrc

openstack image create "manila-service-image" --file manila-service-image-master.qcow2 --disk-format qcow2 --container-format bare --public

# create flavor for manila to use

openstack flavor create s1.manila --ram 256 --disk 0 --vcpus 1 --id 100

exit
