#! /bin/bash
. ./shell/install-centos7.sh

## 安装 mesos
install_mesos

## 卸载 master
uninstall_mesos_master

## 安装 rexay
install_rexray


## 启动docker
start_docker_etcd 'ec2-52-43-231-34.us-west-2.compute.amazonaws.com:2379'

## 启动calico
start_mesos_slave_calico 'ec2-52-43-231-34.us-west-2.compute.amazonaws.com:2379'
