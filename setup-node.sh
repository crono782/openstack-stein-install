#!/bin/bash

# set hostname

# hostnamectl set-hostname <hostname>

# set up networks/ips
# use whatever method you like, but make sure they persist reboot

# stop services we don't want

for i in stop disable;do systemctl $i firewalld NetworkManager;done

# set host entries in lieu of DNS

cat << EOF >> /etc/hosts
10.10.10.51 controller
10.10.10.52 compute
10.10.10.53 network
10.10.10.54 block
10.10.10.55 object
10.10.10.56 dbaas
EOF

# set up NTP

if [ "$(hostname)" == "controller" ]; then
  sed -i 's/^#allow.*/allow 10.10.10.0\/24/' /etc/chrony.conf
else
  sed -i -e '/^server 0/i server controller iburst' -e '/^server [0-9]/d' /etc/chrony.conf
fi

systemctl restart chronyd

# install base openstack packages

yum -y install centos-release-openstack-stein
yum -y update
yum -y install python-openstackclient openstack-selinux

# create some helper scripts

# backs up conf files and removes comments for a clean slate

cat << EOF > bak.sh
#!/bin/sh
filepath=\$1
cp \$filepath \$filepath.bak
grep '^[^#$]' \$filepath.bak > \$filepath
EOF

chmod +x bak.sh

# helper for adding key/value pairs and sections to conf file

cat << EOF > conf.sh
#!/bin/bash
file=\$1
section=\$2
key=\$3
shift;shift;shift
value="\$@"
if [ "\$(grep -c "^\[\$section\]" \$file)" -lt 1  ]; then
  echo [\$section] >> \$file
fi
if [ ! -z "\$(sed -n "/\[\$section\]/,/\[/{/^\$key =.*/=}" \$file)" ]; then
  sed -i "/\[\$section\]/,/\[/{s/\$key[ =].*/\$key = \$value/}" \$file
else
  sed -i "/^\[\$section\]/a \$key = \$value" \$file
fi
EOF

chmod +x conf.sh
