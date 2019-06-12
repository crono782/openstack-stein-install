#!/bin/bash
eptype=$1
epport=$2
ephost=${3:-controller}
for i in public internal admin; do openstack endpoint create --region RegionOne $eptype $i http://$ephost:$epport;done
