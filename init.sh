#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cat << EOF
+--------------------------------------------------------------+
| ===  Centos System init === |
+--------------http://www.iamle.com------------------------+
+----------------------Author:wwek--------------------------+
EOF

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root"
    exit 1
fi

function InitInstall()
{
	cat /etc/issue
	uname -a
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
	echo -e "\n Memory is: ${MemTotal} MB "
	#Set timezone
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	yum install -y ntp
	ntpdate -u pool.ntp.org
	date

	#Disable SeLinux
	echo "selinux status"
	getenforce
	if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0
	echo "selinux is disabled"
	fi

	cp /etc/yum.conf /etc/yum.conf.backup
	sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

	for packages in patch make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap expat expat-devel perl-devel lrzsz subversion vim setuptool ntsysv system-config-firewall-tui system-config-network-tui;
	do yum -y install $packages; done

	mv -f /etc/yum.conf.backup /etc/yum.conf

#disable ipv6
cat << EOF
+--------------------------------------------------------------+
| ===  Disable IPV6 === |
+--------------------------------------------------------------+
EOF
echo "alias net-pf-10 off" >> /etc/modprobe.conf
echo "alias ipv6 off" >> /etc/modprobe.conf
/sbin/chkconfig --level 35 ip6tables off
echo "ipv6 is disabled!"

#vim
sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
echo 'syntax on' > /root/.vimrc

#zh_cn
#sed -i -e 's/^LANG=.*/LANG="zh_CN.UTF-8"/' /etc/sysconfig/i18n

# configure open file limit
cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof
echo ulimit -HSn 65536 >> /etc/rc.local
echo ulimit -HSn 65536 >> /root/.bash_profile
ulimit -HSn 65536

#tunoff services
#--------------------------------------------------------------------------------
cat << EOF
+--------------------------------------------------------------+
| === Tunoff services === |
+--------------------------------------------------------------+
EOF
#---------------------------------------------------------------------------------
for i in `ls /etc/rc3.d/S*`
do
CURSRV=`echo $i|cut -c 15-`

echo $CURSRV
case $CURSRV in
cpuspeed | crond | irqbalance | microcode_ctl | mysqld | mysql | network | nginx | httpd | php-fpm | sendmail | sshd | syslog | rsyslog | snmpd )
#这个启动的系统服务根据具体的应用情况设置，其中network、sshd、syslog是三项必须要启动的系统服务！
echo "Base services, Skip!"
;;
*)
echo "change $CURSRV to off"
chkconfig --level 235 $CURSRV off
service $CURSRV stop
;;
esac
done

#sysctl optimize kernel
rm -rf /etc/sysctl.conf
echo "kernel.core_uses_pid = 1
kernel.msgmax = 65536
kernel.msgmnb = 65536
kernel.shmall = 134217728
kernel.shmmax = 68719476736
kernel.sysrq = 0
net.core.netdev_max_backlog = 30000
net.core.rmem_max = 16777216
net.core.somaxconn = 262144
net.core.wmem_max = 16777216
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.ip_forward = 0
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_wmem = 4096 65536 16777216
vm.swappiness = 6
fs.file-max=65535" >> /etc/sysctl.conf
echo "optimizited kernel configure was done!"
/sbin/sysctl -p /etc/sysctl.conf
/sbin/sysctl -w net.ipv4.route.flush=1
echo "finish all init,just work!"

#update
yum -y update
}
InitInstall 2>&1 | tee /tmp/init-install.log
