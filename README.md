# mesos-marathon

自动安装msos-marathon 脚本，尽量做到一键部署

#### 主要部署插件

1. mesos
2. marahton
3. mesos-dns
4. calico
5. rex-ray


#### How to use
1. add slaves(ip or domain) into servers/slaves
2. ```./shell/deploy``` # copy shell to echo slave
3. ```./shell/setup-master.sh``` to start master in current machine
4. ssh echo slave run ```./shell/setup-slave.sh``` to install and start
