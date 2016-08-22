#! /bin/bash

. ./shell/install-centos7.sh

install_mesos
uninstall_mesos_slave
install_etcd 'ec2-52-43-231-34.us-west-2.compute.amazonaws.com:2379'
start_mesos_master