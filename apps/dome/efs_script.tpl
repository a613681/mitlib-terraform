#!/bin/bash -xe
exec >> /var/log/user-data.log  2>&1
sudo yum install -y nfs-utils
sudo mkdir -p ${efs_mount}
sudo echo "${efs_dns}:/ ${efs_mount} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" >> /etc/fstab
sudo mount -a -t nfs4
