#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
cur_dir=$(pwd)
#set mysql root password
	echo "==========================="

	mysqlrootpwd="root"
	echo "Please input the root password of mysql:"
	read -p "(Default password: root):" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
	fi
	echo "==========================="
	echo "MySQL root password:$mysqlrootpwd"
	echo "==========================="

function CheckAndDownloadFiles()
{
echo "============================check files=================================="
if [ -s php-5.5.18.tar.gz ]; then
 echo "php-5.5.18.tar.gz [found]"
else
 echo "Error: php-5.5.18.tar.gz not found!!!download now......"
 wget -c http://www.php.net/distributions/php-5.5.18.tar.gz
fi

if [ -s pcre-8.35.tar.gz ]; then
  echo "pcre-8.35.tar.gz [found]"
  else
  echo "Error: pcre-8.35.tar.gz not found!!!download now......"
  wget -c  http://dl.iamle.com/linux/soft/pcre-8.35.tar.gz 
fi

if [ -s tengine-2.0.3.tar.gz ]; then
  echo "tengine-2.0.3.tar.gz [found]"
  else
  echo "Error: tengine-2.0.3.tar.gz not found!!!download now......"
  wget -c http://tengine.taobao.org/download/tengine-2.0.3.tar.gz
fi

if [ -s libiconv-1.14.tar.gz ]; then
  echo "libiconv-1.14.tar.gz [found]"
  else
  echo "Error: libiconv-1.14.tar.gz not found!!!download now......"
  wget -c http://dl.iamle.com/linux/soft/libiconv-1.14.tar.gz
  #wget -c http://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz
fi

if [ -s libmcrypt-2.5.8.tar.gz ]; then
  echo "libmcrypt-2.5.8.tar.gz [found]"
  else
  echo "Error: libmcrypt-2.5.8.tar.gz not found!!!download now......"
  wget -c http://dl.iamle.com/linux/soft/libmcrypt-2.5.8.tar.gz
fi

if [ -s mhash-0.9.9.9.tar.gz ]; then
  echo "mhash-0.9.9.9.tar.gz [found]"
  else
  echo "Error: mhash-0.9.9.9.tar.gz not found!!!download now......"
  wget -c http://dl.iamle.com/linux/soft/mhash-0.9.9.9.tar.gz
fi

if [ -s mcrypt-2.6.8.tar.gz ]; then
  echo "mcrypt-2.6.8.tar.gz [found]"
  else
  echo "Error: mcrypt-2.6.8.tar.gz not found!!!download now......"
  wget -c http://dl.iamle.com/linux/soft/mcrypt-2.6.8.tar.gz
#wget -c http://soft.vpser.net/web/mcrypt/mcrypt-2.6.8.tar.gz
fi

if [ -s autoconf-2.69.tar.gz ]; then
  echo "autoconf-2.69.tar.gz [found]"
  else
  echo "Error: autoconf-2.69.tar.gz not found!!!download now......"
  wget -c http://dl.iamle.com/linux/soft/autoconf-2.69.tar.gz 
# wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
fi
echo "============================check files=================================="
}

function InstallDependsAndOpt()
{
cd $cur_dir

tar zxvf autoconf-2.69.tar.gz
cd autoconf-2.69/
./configure --prefix=/usr/local/autoconf-2.69
make && make install
cd ../

tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14/
./configure
make && make install
cd ../

cd $cur_dir
tar zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

cd $cur_dir
tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install
cd ../

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

cd $cur_dir
tar zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install
cd ../

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/lib64/libpng.* /usr/lib/
	ln -s /usr/lib64/libjpeg.* /usr/lib/
fi

ulimit -v unlimited

if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi

ldconfig

}


function InstallMySQL55()
{
echo "============================Install MySQL 5.5=================================="
cd $cur_dir
if [ `getconf LONG_BIT` = '32' ]; then
    echo "Install 32bit percona repo"
    yum -y install http://www.percona.com/downloads/percona-release/percona-release-0.0-1.i386.rpm
elif [ `getconf LONG_BIT` = '64' ]; then
    echo "Install 64bit percona repo"
    yum -y  install http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
fi

yum list | grep percona
yum -y install Percona-Server-client-55 Percona-Server-server-55 Percona-Server-shared-55
#mv /var/lib/mysql/ /data/
#rm -f /etc/my.cnf
mv /etc/my.cnf /etc/my.cnf.backup
cp -f conf/my.cnf /etc/
mkdir -p /data/mysql
/usr/bin/mysql_install_db --defaults-file=/etc/my.cnf  --datadir=/data/mysql --user=mysql
chown -R mysql /data/mysql
chgrp -R mysql /data/mysql
chown -R mysql:mysql /data/mysql
/etc/init.d/mysql start
/usr/bin/mysqladmin -u root password $mysqlrootpwd -S /tmp/mysql.sock
cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/bin/mysql -u root -p$mysqlrootpwd -h localhost -S /tmp/mysql.sock  < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

/etc/init.d/mysql restart
echo "============================MySQL 5.5 install completed========================="
}

function InstallPHP55()
{
echo "============================Install PHP 5.5.11================================"
cd $cur_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.69/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.69/bin/autoheader
tar zxvf php-5.5.18.tar.gz
cd php-5.5.18/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo --enable-opcache
make ZEND_EXTRA_LIBS='-liconv'
make install

rm -f /usr/bin/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

echo "Copy new php configure file."
mkdir -p /usr/local/php/etc
cp php.ini-production /usr/local/php/etc/php.ini

cd $cur_dir
# php extensions
echo "Modify php.ini......"
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php/etc/php.ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php/etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini

echo "Install  Zend OPcache for php5.5.x"

echo "Write  Zend OPcache to php.ini......"
cat >>/usr/local/php/etc/php.ini<<EOF
;opcache
zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/opcache.so
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
opcache.enable=0
EOF

echo "Creating new php-fpm configure file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen.owner = www
listen.group = www
listen.mode = 0660
listen = /tmp/php-cgi.sock
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 200
EOF

echo "Copy php-fpm init.d file......"
cp $cur_dir/php-5.5.18/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

cp $cur_dir/lnmp /root/lnmp
chmod +x /root/lnmp
sed -i 's:/usr/local/php/logs:/usr/local/php/var/run:g' /root/lnmp
echo "============================PHP 5.5.11 install completed======================"
}

function InstallNginx()
{
echo "============================Install Nginx================================="
groupadd www
useradd -s /sbin/nologin -g www www
cd $cur_dir
tar zxvf pcre-8.35.tar.gz
cd pcre-8.35/
./configure
make && make install
cd ../

ldconfig

tar zxvf tengine-2.0.3.tar.gz
cd tengine-2.0.3/
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6
make && make install
cd ../

ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

#rm -f /usr/local/nginx/conf/nginx.conf
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.backup
cd $cur_dir
cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
cp conf/none.conf /usr/local/nginx/conf/none.conf

rm -f /usr/local/nginx/conf/fcgi.conf
rm -f /usr/local/nginx/conf/fastcgi.conf
cp conf/fastcgi.conf /usr/local/nginx/conf/fastcgi.conf

cd $cur_dir
cp vhost.sh /root/vhost.sh
chmod +x /root/vhost.sh

mkdir -p /data/wwwroot/default
chmod +w /data/wwwroot/default
mkdir -p /data/wwwlogs
chmod 777 /data/wwwlogs

chown -R www:www /data/wwwroot/default
}

function CreatPHPTools()
{
echo "Create PHP Info Tool..."

echo "Copy PHP Prober..."
cd $cur_dir
cp conf/tz.php /data/wwwroot/default/tz.php

cp conf/index.html /data/wwwroot/default/index.html
}

function AddAndStartup()
{
echo "============================add nginx and php-fpm on startup============================"
cp init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

chkconfig --level 345 php-fpm on
chkconfig --level 345 nginx on
chkconfig --level 345 mysql on
echo "===========================add nginx and php-fpm on startup completed===================="
echo "Starting LNMP..."
/etc/init.d/mysql start
/etc/init.d/php-fpm start
/etc/init.d/nginx start

#add 80 port to iptables
if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/sbin/iptables-save
fi
}

function CheckInstall()
{
echo "===================================== Check install ==================================="
clear
isnginx=""
ismysql=""
isphp=""
echo "Checking..."
if [ -s /usr/local/nginx ] && [ -s /usr/local/nginx/sbin/nginx ]; then
  echo "Nginx: OK"
  isnginx="ok"
  else
  echo "Error: /usr/local/nginx not found!!!Nginx install failed."
fi

if [ -s /usr/local/php/sbin/php-fpm ] && [ -s /usr/local/php/etc/php.ini ] && [ -s /usr/local/php/bin/php ]; then
  echo "PHP: OK"
  echo "PHP-FPM: OK"
  isphp="ok"
  else
  echo "Error: /usr/local/php not found!!!PHP install failed."
fi

if [ -s /usr/bin/mysql ] && [ -s /etc/my.cnf ]; then
  echo "MySQL: OK"
  ismysql="ok"
  else
  echo "Error: /usr/bin/mysql not found!!!MySQL install failed."
fi
if [ "$isnginx" = "ok" ] && [ "$ismysql" = "ok" ] && [ "$isphp" = "ok" ]; then
echo "Install lnmp  completed! enjoy it."
echo "========================================================================="
echo ""
echo "lnmp status manage: /root/lnmp {start|stop|reload|restart|kill|status}"
echo "default mysql root password:$mysqlrootpwd"
echo "Prober : http://yourIP/tz.php"
echo "Add VirtualHost : /root/vhost.sh"
echo ""
echo "The path of some dirs:"
echo "mysql data dir:   /data/mysql"
echo "php dir:     /usr/local/php"
echo "nginx dir:   /usr/local/nginx"
echo "web dir :     /data/wwwroot/default"
echo ""
echo "========================================================================="
/root/lnmp status
netstat -ntl
else
echo "Sorry,Failed to install LNMP!"
echo "http://github.com/wwek/oneshell http://www.iamle.com"
fi
}

CheckAndDownloadFiles 2>&1 | tee -a /tmp/lnmp-install.log
InstallDependsAndOpt 2>&1 | tee -a /tmp/lnmp-install.log
InstallMySQL55 2>&1 | tee -a /tmp/lnmp-install.log
InstallPHP55 2>&1 | tee -a /tmp/lnmp-install.log
InstallNginx 2>&1 | tee -a /tmp/lnmp-install.log
CreatPHPTools 2>&1 | tee -a /tmp/lnmp-install.log
AddAndStartup 2>&1 | tee -a /tmp/lnmp-install.log
CheckInstall 2>&1 | tee -a /tmp/lnmp-install.log
