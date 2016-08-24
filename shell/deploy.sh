#! /bin/bash
. ./shell/install-centos7.sh

## 暂时master不做一键部署
## install_mesos

USER_NEME='ec2-user'
MASTER='ec2-52-43-231-34.us-west-2.compute.amazonaws.com'

for slave in `cat ./servers/slaves`
do
	scp -r ../mesos-marathon $USER_NEME@$slave:~/
	ssh $USER_NEME@$slave "echo "$slave" > ~/mesos-marathon/slave"
	ssh $USER_NEME@$slave "echo "$MASTER" > ~/mesos-marathon/master"
done