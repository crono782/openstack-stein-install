#!/bin/bash

# some verifications

source ~/dqueenrc

swift stat
openstack container create container1
echo "swift test file" > swiftfile.txt
openstack object create container1 swiftfile.txt
openstack object list container1
rm -f swiftfile.txt
openstack object save container1 swiftfile.txt
cat swiftfile.txt
rm -f swiftfile.txt
openstack object delete container1 swiftfile.txt
openstack container delete container1

exit
