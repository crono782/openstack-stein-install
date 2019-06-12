#!/bin/bash

# verification (should show 4 agents on network node and 1 on each compute) 

source ~/adminrc

openstack network agent list

exit
