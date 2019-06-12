#!/bin/bash

# discover compute hosts

source ~/adminrc

openstack compute service list --service nova-compute

su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

# do some verifications

openstack compute service list

openstack catalog list

openstack image list

nova-status upgrade check

exit
