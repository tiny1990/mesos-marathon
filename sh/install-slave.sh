#! /bin/bash
. ./sh/install-centos7.sh


## 安装 mesos
install_mesos

## 安装 rexay
install_rexray 'key' 'gen'
