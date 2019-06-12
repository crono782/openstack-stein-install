#!/bin/bash

# make some controller specific helper scripts

# script for adding service endpoints

cat << EOF > endpoint.sh
#!/bin/bash
eptype=\$1
epport=\$2
ephost=\${3:-controller}
for i in public internal admin; do openstack endpoint create --region RegionOne \$eptype \$i http://\$ephost:\$epport;done
EOF

chmod +x endpoint.sh

# script for creating mysql project dbs

cat << EOF > dbcreate.sh
#!/bin/bash
dbname=\$1
dbuser=\$2
pass=\$3
cat << EOS > ~/.sqlfiles/\$dbname-\$dbuser.sql
CREATE DATABASE \$dbname;
GRANT ALL PRIVILEGES ON \$dbname.* TO '\$dbuser'@'localhost' IDENTIFIED BY '\$pass';
GRANT ALL PRIVILEGES ON \$dbname.* TO '\$dbuser'@'%' IDENTIFIED BY '\$pass';
EOS
mysql -u root -ppassword < ~/.sqlfiles/\$dbname-\$dbuser.sql
EOF

chmod +x dbcreate.sh

# create basic rc files

# rc file for admin user

cat << EOF > adminrc
black=\$(tput setaf 0)
red=\$(tput setaf 1)
green=\$(tput setaf 2)
yellow=\$(tput setaf 3)
blue=\$(tput setaf 4)
magenta=\$(tput setaf 5)
cyan=\$(tput setaf 6)
white=\$(tput setaf 7)
reset=\$(tput sgr0)
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export PS1='[\u@\h \[\$red\](\$OS_USERNAME:\$OS_PROJECT_NAME)\[\$reset\] \W]\$ '
EOF

# rc file to reset settings

cat << EOF > norc
unset OS_PROJECT_DOMAIN_NAME
unset OS_USER_DOMAIN_NAME
unset OS_PROJECT_NAME
unset OS_USERNAME
unset OS_PASSWORD
unset OS_AUTH_URL
unset OS_IDENTITY_API_VERSION
unset OS_IMAGE_API_VERSION
export PS1='[\u@\h \W]\$ '
EOF

# set up SSH keys for convenience

#ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa

#for i in controller compute network block object dbaas;do ssh-copy-id -o StrictHostKeyChecking=no $i;done

# install/setup mysql database

yum -y install mariadb mariadb-server python2-PyMySQL

cat << EOF > /etc/my.cnf.d/openstack.cnf
[mysqld]
bind-address = 10.10.10.51
default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF

for i in enable start;do systemctl $i mariadb;done

# manual mysql setup (not using this currently)

#mysql_secure_installation

# auto mysql setup (using this instead)

mysql -e "UPDATE mysql.user SET Password = PASSWORD('password') WHERE User = 'root'"
mysql -e "DROP USER ''@'localhost'"
mysql -e "DROP USER ''@'$(hostname)'"
mysql -e "DROP DATABASE test"
mysql -e "FLUSH PRIVILEGES"

mkdir ~/.sqlfiles # << for dbcreate script usage

# install/stup message queue

yum -y install rabbitmq-server

for i in enable start;do systemctl $i rabbitmq-server;done

rabbitmqctl add_user openstack password

rabbitmqctl set_permissions openstack ".*" ".*" ".*"

# install/setup memcached

yum -y install memcached python-memcached

sed -i 's/OPTIONS="-l 127.0.0.1,::1"/OPTIONS="-l 127.0.0.1,::1,controller"/' /etc/sysconfig/memcached

for i in enable start;do systemctl $i memcached;done

# install/setup etcd

yum -y install etcd

sed -r -e '/(ETCD_LISTEN|ETCD_INITIAL)/ s/^#//' -e 's/localhost/10.10.10.51/g' -e '/(ETCD_NAME|ETCD_INITIAL)/ s/default/controller/' -e 's/(etcd-cluster)/\1-01/' /etc/etcd/etcd.conf

for i in enable start;do systemctl $i etcd;done

exit
