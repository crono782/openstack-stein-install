#!/bin/bash

# install packages

yum -y install openstack-dashboard

# config work

cp -p /etc/openstack-dashboard/local_settings /etc/openstack-dashboard/local_settings.bkp

sed -i 's/^OPENSTACK_HOST.*/OPENSTACK_HOST = "controller"/' /etc/openstack-dashboard/local_settings
sed -i "s/^ALLOWED_HOSTS.*/ALLOWED_HOSTS = ['*']/" /etc/openstack-dashboard/local_settings
sed -i '/^#CACHES/,/\}$/{s/^#//;s/127.0.0.1/controller/}' /etc/openstack-dashboard/local_settings
sed -i "s/#\+SESSION_ENGINE.*/SESSION_ENGINE = 'django.contrib.sessions.backends.cache'/" /etc/openstack-dashboard/local_settings 
sed -i '/OPENSTACK_API_VERSIONS/,/\}/{/compute/! s/^#//}' /etc/openstack-dashboard/local_settings
sed -i 's/^OPENSTACK_KEYSTONE_DEFAULT_ROLE.*/OPENSTACK_KEYSTONE_DEFAULT_ROLE = "member"/' /etc/openstack-dashboard/local_settings

sed -i '1iWSGIApplicationGroup %{GLOBAL}' /etc/httpd/conf.d/openstack-dashboard.conf 

# restart services

systemctl restart httpd memcached

exit
