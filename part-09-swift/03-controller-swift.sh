#!/bin/bash

# create initial rings

cd /etc/swift

swift-ring-builder account.builder create 10 3 1
for i in b c d;do swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.10.10.55 --port 6202 --device vd$i --weight 100;done
swift-ring-builder account.builder rebalance
swift-ring-builder account.builder

swift-ring-builder container.builder create 10 3 1
for i in b c d;do swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.10.10.55 --port 6201 --device vd$i --weight 100;done
swift-ring-builder container.builder rebalance
swift-ring-builder container.builder

swift-ring-builder object.builder create 10 3 1
for i in b c d;do swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.10.10.55 --port 6200 --device vd$i --weight 100;done
swift-ring-builder object.builder rebalance
swift-ring-builder object.builder

cd ~

# distribute ring files to object node

scp /etc/swift/*.gz object:/etc/swift/

# back up swift.conf file and download new one

cp -p /etc/swift/swift.conf /etc/swift/swift.conf.orig
curl -o /etc/swift/swift.conf https://opendev.org/openstack/swift/raw/branch/stable/stein/etc/swift.conf-sample

# conf file work

./bak.sh /etc/swift/swift.conf

./conf.sh /etc/swift/swift.conf swift-hash swift_hash_path_suffix swifthashsuffix
./conf.sh /etc/swift/swift.conf swift-hash swift_hash_path_prefix swifthashprefix
./conf.sh /etc/swift/swift.conf storage-policy:0 name Policy-0
./conf.sh /etc/swift/swift.conf storage-policy:0 default yes

# distribute swift.conf to object node

scp /etc/swift/swift.conf object:/etc/swift/

# ensure proper ownership of swift dir

chown -R root:swift /etc/swift

# start services

for i in enable start;do systemctl $i openstack-swift-proxy memcached;done

exit
