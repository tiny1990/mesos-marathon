#! /bin/bash
. ./shell/install-centos7.sh

## 安装 mesos
install_mesos

## 卸载 master
uninstall_mesos_master

## 安装启动 rexay
install_rexray

## 启动calico
start_mesos_slave_calico