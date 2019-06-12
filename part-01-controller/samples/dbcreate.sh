#!/bin/bash
dbname=$1
dbuser=$2
pass=$3
cat << EOS > ~/.sqlfiles/$dbname-$dbuser.sql
CREATE DATABASE $dbname;
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost' IDENTIFIED BY '$pass';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'%' IDENTIFIED BY '$pass';
EOS
mysql -u root -ppassword < ~/.sqlfiles/$dbname-$dbuser.sql
