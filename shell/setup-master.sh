#! /bin/bash

. ./shell/install-centos7.sh

MASTER_IP=$(cat master)

# 安装 mesos
install_mesos

# 卸载mesos_slaves
uninstall_mesos_slave

# 安装etcd
install_etcd $MASTER_IP:2379

# 安装zk
install_zookeeper

# 启动mesos－master
start_mesos_master

# 启动zk
start_zookeeper

# 启动marathon
start_mesos_marathon $MASTER_IP:5050 $MASTER_IP:2181