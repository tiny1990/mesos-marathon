#! /bin/bash
. ./shell/install-centos7.sh

MASTER_IP=$(cat ./master)
SLAVE_IP=$(cat ./slave)

## 安装 mesos
install_mesos

## 卸载 master
uninstall_mesos_master

## 安装 rexay
install_rexray 'key' 'gen'


## 启动docker  
start_docker_etcd $MASTER_IP:2379

## 启动calico etcd 
start_mesos_slave_calico $MASTER_IP:2379

## 启动slave
start_mesos_slave $MASTER_IP:5050 $SLAVE_IP