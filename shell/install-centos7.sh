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
	sudo systemctl stop marathon.service
	sudo systemctl disable marathon.service
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
	#  --enable_features external_volumes is not support?
	sudo marathon --master $1:5050 --hostname $1 --zk zk://$2 --http_port 8888 &
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

## $1 is mesos-master ip
## $2 is mesos-dns ip (local ip)
start_mesos_dns()
{
	## TODO
	sudo mkdir -p /usr/local/mesos-dns/
	sudo wget -O /usr/local/mesos-dns/mesos-dns  https://github.com/mesosphere/mesos-dns/releases/download/v0.5.2/mesos-dns-v0.5.2-linux-amd64
    sudo chmod +x /usr/local/mesos-dns/mesos-dns
	sudo bash -c 'cat >/usr/local/mesos-dns/config.json <<EOF
{
  "masters": ["MASTER:5050"],
  "ZkDetectionTimeout": 0,
  "refreshSeconds": 60,
  "ttl": 60,
  "domain": "mesos",
  "port": 53,
  "resolvers": ["8.8.8.8"],
  "timeout": 5,
  "httpon": true,
  "dnson": true,
  "httpport": 8123,
  "externalon": true,
  "listener": "0.0.0.0",
  "SOAMname": "ns1.mesos",
  "SOARname": "root.ns1.mesos",
  "SOARefresh": 60,
  "SOARetry":   600,
  "SOAExpire":  86400,
  "SOAMinttl": 60,
  "IPSources": [ "netinfo","mesos","host"]
}
EOF'
	sudo sed -i 's/MASTER/'$1'/g' /usr/local/mesos-dns/config.json
    sudo sed -i '1s/^/nameserver '$2'\n /' /etc/resolv.conf
    sudo /usr/local/mesos-dns/mesos-dns -config /usr/local/mesos-dns/config.json &
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
