#!/bin/bash

# install packages

yum -y install openstack-neutron openstack-neutron-openvswitch libibverbs ebtables

# init openvswitch

for i in enable start;do systemctl $i openvswitch;done

# create provider bridge

ovs-vsctl add-br br-provider
ovs-vsctl add-port eth2 br-provider

# create provider bridge network script

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-provider
TYPE="OVSBridge"
BOOTPROTO="none"
DEFROUTE="no"
IPV6INIT="no"
NAME="br-provider"
DEVICE="br-provider"
DEVICETYPE="ovs"
ONBOOT="yes"
EOF

# reconfigure interface network script

sed -i -e 's/^TYPE=.*/TYPE="OVSPort"/' -e '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth2
cat << EOF >> /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICETYPE="ovs"
OVS_BRIDGE="br-provider"
EOF

# reset bridge and port
ifdown br-provider
ifdown eth2
ifup br-provider
ifup eth2

# quick verification

ovs-vsctl show

# conf file work

./bak.sh /etc/neutron/neutron.conf

./conf.sh /etc/neutron/neutron.conf DEFAULT core_plugin ml2
./conf.sh /etc/neutron/neutron.conf DEFAULT service_plugins router
./conf.sh /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips true
./conf.sh /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:password@controller
./conf.sh /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
./conf.sh /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes true
./conf.sh /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes true
./conf.sh /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://controller:5000
./conf.sh /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:5000
./conf.sh /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
./conf.sh /etc/neutron/neutron.conf keystone_authtoken auth_type password
./conf.sh /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
./conf.sh /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
./conf.sh /etc/neutron/neutron.conf keystone_authtoken project_name service
./conf.sh /etc/neutron/neutron.conf keystone_authtoken username neutron
./conf.sh /etc/neutron/neutron.conf keystone_authtoken password password
./conf.sh /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp

./bak.sh /etc/neutron/plugins/ml2/openvswitch_agent.ini

./conf.sh /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings provider:br-provider
./conf.sh /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs local_ip 10.10.20.53
./conf.sh /etc/neutron/plugins/ml2/openvswitch_agent.ini agent tunnel_types vxlan
./conf.sh /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population True
./conf.sh /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup firewall_driver iptables_hybrid

./bak.sh /etc/neutron/l3_agent.ini

./conf.sh /etc/neutron/l3_agent.ini DEFAULT interface_driver openvswitch
# empty quotes so we get a intentionally blank value
./conf.sh /etc/neutron/l3_agent.ini DEFAULT external_network_bridge ''

./bak.sh /etc/neutron/dhcp_agent.ini

./conf.sh /etc/neutron/dhcp_agent.ini DEFAULT interface_driver openvswitch
./conf.sh /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
./conf.sh /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata true

./bak.sh /etc/neutron/metadata_agent.ini

./conf.sh /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_host controller
./conf.sh /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret metasecret

# start services

for i in enable start;do systemctl $i neutron-{openvswitch,dhcp,metadata,l3}-agent;done

exit
