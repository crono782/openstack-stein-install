#!/bin/bash


# ensure proper ownership of swift dir

chown -R root:swift /etc/swift

# fix selinux

chcon -R system_u:object_r:swift_data_t:s0 /srv/node

for i in enable start;do systemctl $i openstack-swift-account{,-auditor,-reaper,-replicator};done
for i in enable start;do systemctl $i openstack-swift-container{,-auditor,-replicator,-updater};done
for i in enable start;do systemctl $i openstack-swift-object{,-auditor,-replicator,-updater};done

exit
