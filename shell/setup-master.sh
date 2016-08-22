#! /bin/bash

. ./shell/install-centos7.sh

MASTER_IP=$(cat master)
SLAVE_IP=$(cat slave)


install_mesos
uninstall_mesos_slave
install_etcd '$MASTER_IP:2379'
install_zookeeper

start_mesos_master
start_zookeeper

start_mesos_marathon '$MASTER_IP:5050' '$MASTER_IP:2181'