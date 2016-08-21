#! /bin/bash

USER_NEME='ec2-user'
install_mesos()
{
	sudo rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
	wget wget https://github.com/tiny1990/mesos-marathon/blob/master/package/libevent-devel-2.0.21-4.el7.i686.rpm
	sudo yum install -y ./libevent-devel-2.0.21-4.el7.i686.rpm
	rm ./libevent-devel-2.0.21-4.el7.i686.rpm
	sudo yum -y install mesos	
}

install_rexray()
{
sudo curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable 0.3.3
sudo bash -c 'cat >/etc/rexray/config.yml <<EOF
rexray:
  storageDrivers:
  - ec2
aws:
  accessKey: AKIAPLEK2FOXVZEIUWEQ
  secretKey: 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
EOF'
sudo rexray start -c /etc/rexray/config.yml
}

uninstall_mesos_slave()
{
	sudo systemctl stop mesos-slave.service
	sudo systemctl disable mesos-slave.service
}

start_mesos_master()
{
	sudo mesos-master --ip=0.0.0.0 --work_dir=/var/lib/mesos  &
}


start_mesos_slave()
{
	sudo mesos-slave --master=$1  --advertise_ip=$2 --containerizers=docker,mesos  --work_dir=/var/lib/mesos --enable_features external_volume &
}

start_mesos_slave_calico()
{
	sudo docker pull calico/node:v0.20.0
	sudo docker pull calico/node-libnetwork:v0.8.0
	sudo ETCD_AUTHORITY=$1 calicoctl node --libnetwork
	sudo ETCD_AUTHORITY=$1 calicoctl pool add 192.168.0.0/16 --ipip --nat-outgoing
}



#for slave in `cat ./slaves`
#do
#	echo $slave
#	ssh $USER_NEME@$slave 'start_mesos_slave'
#done