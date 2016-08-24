#! /bin/bash


install_mesos()
{
	sudo rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
	wget https://github.com/tiny1990/mesos-marathon/raw/master/package/libevent-devel-2.0.21-4.el7.i686.rpm
	sudo yum install -y ./libevent-devel-2.0.21-4.el7.i686.rpm
	rm ./libevent-devel-2.0.21-4.el7.i686.rpm
	sudo yum -y install mesos	
}

install_marathon()
{
	sudo yum -y install marathon
}

install_rexray()
{
sudo curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable 0.3.3
#sudo bash -c 'cat >/etc/rexray/config.yml <<EOF
#rexray:
#  storageDrivers:
#  - ec2
#aws:
#  accessKey:$1
#  secretKey:$2
#EOF'
export REXRAY_STORAGEDRIVERS=ec2
export AWS_ACCESSKEY=$1
export AWS_SECRETKEY=$2
sudo rexray service start
#sudo rexray start -c /etc/rexray/config.yml
}

uninstall_mesos_slave()
{
	sudo systemctl stop mesos-slave.service
	sudo systemctl disable mesos-slave.service
}

uninstall_mesos_master()
{
	sudo systemctl stop mesos-master.service
	sudo systemctl disable mesos-master.service
}


install_etcd()
{
curl -L https://github.com/coreos/etcd/releases/download/v3.0.6/etcd-v3.0.6-linux-amd64.tar.gz -o etcd-v3.0.6-linux-amd64.tar.gz
tar xzvf etcd-v3.0.6-linux-amd64.tar.gz && cd etcd-v3.0.6-linux-amd64
./etcd \
--listen-peer-urls http://0.0.0.0:2380 \
--listen-client-urls http://0.0.0.0:2379 \
--advertise-client-urls http://$1 &
cd ..
}

install_zookeeper()
{
	sudo yum -y install mesosphere-zookeeper
}

start_zookeeper()
{
	sudo service zookeeper restart
}

start_mesos_master()
{
	sudo mesos-master --ip=0.0.0.0 --work_dir=/var/lib/mesos  &
}

start_mesos_marathon()
{
	sudo marathon --master $1:5050 --hostname $1 --zk zk://$2 --http_port 8888  --enable_features external_volumes &
}

start_mesos_slave()
{
	sudo mesos-slave --master=$1  --advertise_ip=$2 --containerizers=docker,mesos  --work_dir=/var/lib/mesos &
}

start_mesos_slave_calico()
{
	wget http://www.projectcalico.org/builds/calicoctl
	chmod +x calicoctl
	sudo mv calicoctl /bin
	sudo docker pull calico/node-libnetwork:latest
	sudo docker pull calico/node:latest
	sudo ETCD_AUTHORITY=$1 calicoctl node --libnetwork
	sudo ETCD_AUTHORITY=$1 calicoctl pool add 192.168.0.0/16 --ipip --nat-outgoing
	sudo docker network create --driver calico --ipam-driver calico datapipeline 
}

start_mesos_dns()
{
	## TODO
	echo aaa
}

start_docker_etcd()
{
	sudo docker daemon --cluster-store=etcd://$1 &
}



#for slave in `cat ./slaves`
#do
#	echo $slave
#	ssh $USER_NEME@$slave 'start_mesos_slave'
#done
