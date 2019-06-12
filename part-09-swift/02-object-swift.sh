#!/bin/bash

# install prereq packages

yum -y install xfsprogs rsync

# prepare disks, create mount points, add to fstab, and mount

for i in b c d;do
  #mkfs.xfs /dev/vd$i
  mkdir -p /srv/node/vd$i
  echo /dev/vd$i /srv/node/vd$i xfs noatime,nodiratime,nobarrier,logbufs=8 0 2 >> /etc/fstab
  mount /srv/node/vd$i
done

cat << EOF >> /etc/rsyncd.conf
uid = swift
gid = swift
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = 10.10.10.55

[account]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/account.lock

[container]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/container.lock

[object]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/object.lock
EOF

# enable and start services

for i in enable start;do systemctl $i rsyncd;done

# install packages

yum -y install openstack-swift-account openstack-swift-container openstack-swift-object

# archive original conf files and download new ones

for i in account container object;do
  cp -p /etc/swift/$i-server.conf /etc/swift/$i-server.conf.orig
  curl -o /etc/swift/$i-server.conf https://opendev.org/openstack/swift/raw/branch/stable/stein/etc/$i-server.conf-sample
done

# conf file work

./bak.sh /etc/swift/account-server.conf

./conf.sh /etc/swift/account-server.conf DEFAULT bind_ip 10.10.10.55
./conf.sh /etc/swift/account-server.conf DEFAULT bind_port 6202
./conf.sh /etc/swift/account-server.conf DEFAULT user swift
./conf.sh /etc/swift/account-server.conf DEFAULT swift_dir /etc/swift
./conf.sh /etc/swift/account-server.conf DEFAULT devices /srv/node
./conf.sh /etc/swift/account-server.conf DEFAULT mount_check True
./conf.sh /etc/swift/account-server.conf pipeline:main pipeline 'healthcheck recon account-server'
./conf.sh /etc/swift/account-server.conf filter:recon use egg:swift#recon
./conf.sh /etc/swift/account-server.conf filter:recon recon_cache_path /var/cache/swift

./bak.sh /etc/swift/container-server.conf

./conf.sh /etc/swift/container-server.conf DEFAULT bind_ip 10.10.10.55
./conf.sh /etc/swift/container-server.conf DEFAULT bind_port 6201
./conf.sh /etc/swift/container-server.conf DEFAULT user swift
./conf.sh /etc/swift/container-server.conf DEFAULT swift_dir /etc/swift
./conf.sh /etc/swift/container-server.conf DEFAULT devices /srv/node
./conf.sh /etc/swift/container-server.conf DEFAULT mount_check True
./conf.sh /etc/swift/container-server.conf pipeline:main pipeline 'healthcheck recon container-server'
./conf.sh /etc/swift/container-server.conf filter:recon use egg:swift#recon
./conf.sh /etc/swift/container-server.conf filter:recon recon_cache_path /var/cache/swift

./bak.sh /etc/swift/object-server.conf

./conf.sh /etc/swift/object-server.conf DEFAULT bind_ip 10.10.10.55
./conf.sh /etc/swift/object-server.conf DEFAULT bind_port 6200
./conf.sh /etc/swift/object-server.conf DEFAULT user swift
./conf.sh /etc/swift/object-server.conf DEFAULT swift_dir /etc/swift
./conf.sh /etc/swift/object-server.conf DEFAULT devices /srv/node
./conf.sh /etc/swift/object-server.conf DEFAULT mount_check True
./conf.sh /etc/swift/object-server.conf pipeline:main pipeline 'healthcheck recon object-server'
./conf.sh /etc/swift/object-server.conf filter:recon use egg:swift#recon
./conf.sh /etc/swift/object-server.conf filter:recon recon_cache_path /var/cache/swift

# set permissions

chown -R swift:swift /srv/node

# make sure cache dir is created and permissions are set

mkdir -p /var/cache/swift
chown -R root:swift /var/cache/swift
chmod -R 775 /var/cache/swift

exit
