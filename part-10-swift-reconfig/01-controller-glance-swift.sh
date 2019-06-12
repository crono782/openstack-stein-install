#!/bin/bash

# conf file work

./conf.sh /etc/glance/glance-api.conf glance_store stores swift,file,http
./conf.sh /etc/glance/glance-api.conf glance_store default_store swift
./conf.sh /etc/glance/glance-api.conf glance_store swift_store_create_container_on_put True

exit
