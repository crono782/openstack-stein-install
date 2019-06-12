#!/bin/bash

# enable backup feature in horizon

sed -i '/OPENSTACK_CINDER_FEATURES/,/\}/ s/False/True/' /etc/openstack-dashboard/local_settings

systemctl restart httpd

exit
