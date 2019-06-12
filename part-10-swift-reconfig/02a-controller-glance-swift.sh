#!/bin/bash

# conf file work

./conf.sh /etc/glance/glance-api.conf glance_store default_swift_reference glance-swift
./conf.sh /etc/glance/glance-api.conf glance_store swift_store_config_file /etc/glance/glance-swift.conf

cat << EOF >> /etc/glance/glance-swift.conf
[glance-swift]
user = service:glance
key = password
user_domain_id = default
project_domain_id = default
auth_version = 3
auth_address = http://controller:5000/v3
EOF

# restart api

systemctl restart openstack-glance-api

exit
