#! /bin/bash
. ./shell/install-centos7.sh

## 暂时master不做一键部署
## install_mesos

USER_NEME='ec2-user'
MASTER='ec2-52-43-231-34.us-west-2.compute.amazonaws.com:2379'

for slave in `cat ./servers/slaves`
do
	scp -r ../mesos-marathon $USER_NEME@$slave:~/
	#ssh $USER_NEME@$slave 'sudo mesos-slave --master=$MASTER  --advertise_ip=$slave --containerizers=docker,mesos  --work_dir=/var/lib/mesos --enable_features external_volume &'
done

