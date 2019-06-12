#!/bin/bash

# create keystone database

./dbcreate.sh keystone keystone password

# install packages

yum -y install openstack-keystone httpd mod_wsgi

# conf file work
./bak.sh /etc/keystone/keystone.conf

./conf.sh /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:password@controller/keystone
./conf.sh /etc/keystone/keystone.conf token provider fernet

# sync database

su -s /bin/sh -c "keystone-manage db_sync" keystone

# initialize fernet

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

# bootstrap keystone

keystone-manage bootstrap --bootstrap-password password \
  --bootstrap-admin-url http://controller:5000/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne

# setup/initialize apache/wsgi
sed -i 's/^#ServerName.*/ServerName controller/' /etc/httpd/conf/httpd.conf

ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

for i in enable start;do systemctl $i httpd;done

# create basic projects and roles

source ~/adminrc

openstack project create --domain default --description "Service Project" service

openstack project create --domain default --description "Learnoss Project" learnoss

openstack user create --domain default --password password dqueen

if [ "$(openstack role list -c Name -f value|grep -c '^member$')" -lt 1 ]; then openstack role create member;fi

openstack role add --project learnoss --user dqueen member

cp ~/adminrc ~/dqueenrc

sed -i -e '/OS_PROJECT_NAME/ s/admin/learnoss/'\
 -e '/OS_USERNAME/ s/admin/dqueen/'\
 -e '/OS_PASSWORD/ s/password/password/'\
 -e '/PS1/ s/$red/$yellow/' ~/dqueenrc

exit
