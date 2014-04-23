oneshell
========

一些Linux Bash Shell 一键脚本,所有脚本只支持CentOS，RedHat未做测试，理论没问题。
主要是自用，避免重复劳动。


脚本文件单个介绍
========

init.sh
--------
初始化CentOS linux生产环境。只能用于新系统初始化。
其中包括内容有：
设置时区为UTC+8,ntpdate 同步
禁用SeLinux
yum 安装常用库
禁用ipv6
优化打开文件数
禁用不必要的services
优化sysctl

rmamp.sh
--------
删除yum二进制包方式安装的apache（httd），mysql，php

lnmp2centos.sh
==============
本LNMP一键安装脚本，安装的软件为：
Nginx(Tengine new)：       使用最新版，Tengine是taobao维护的版本，全兼容nginx的配置，更多特性，推荐使用。
MySQL(Percona Server5.6)： "Percona Server" oschina、douban都在使用，我也选她。全兼容官方mysql配置。
PHP(php5.5.x)              使用php5.5.x最新版。

使用方法：
wget -c https://github.com/wwek/oneshell/archive/master.zip;yum -y install  unzip;unzip master.zip;cd oneshell-master;sh init.sh;sh lnmp2centos.sh
特别注意：lnmp2centos.sh 不能单独使用，必须和 init.sh 配合使用。

参考lnmp.org定制本一键脚本。

