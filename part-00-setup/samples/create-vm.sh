# examples showing creating different vms with multiple block devices, nics, or special cpu profiles

# example showing vm w/ nested kvm cpu profile and multiple networks (i.e. compute node)
virt-install -n compute --os-type=Linux --os-variant=centos7.0 --import --disk path=compute.qcow2 --ram=8192 --vcpus=2 --cpu host-passthrough --network=bridge:br-mgmt --network=bridge:br-tnt --nographics

# example showing vm w/ multiple networks (i.e. network node)
virt-install -n network --os-type=Linux --os-variant=centos7.0 --import --disk path=network.qcow2 --ram=1024 --vcpus=1 --network=bridge:br-mgmt -network=bridge:br-tnt --network=bridge:br-prv --nographics

# example showing vm w/ multiple disks (i.e. block node)
virt-install -n block --os-type=Linux --os-variant=centos7.0 --import --disk path=block.qcow2 --disk path=block1.qcow2 --disk path=block2.qcow2 --ram=1024 --vcpus=1 --network=bridge:br-mgmt --nographics
