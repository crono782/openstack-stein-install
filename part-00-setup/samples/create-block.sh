# examples showing creating thin block devices or images w/ backing stores

# example creating 20G block device, but thin provisioned
qemu-img create -f qcow2 object1.qcow2 20G

# example "cloning block device using a backing store" (thin clone)
qemu-img create -f qcow2 -F qcow2 -b centos7tpl.qcow2 controller.qcow2
