#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
echo "========================================================================="
echo "Upgrade PHP for LNMP"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "PHP version at php5.5.12 php5.4.27 php5.3.28"
echo "========================================================================="
cur_dir=$(pwd)

if [ "$1" != "--help" ]; then

old_php_version=`/usr/local/php/bin/php -r 'echo PHP_VERSION;'`
#echo $old_php_version

#set php version

	php_version=""
	echo "Current PHP Version:$old_php_version"
	echo "You can get version number from http://www.php.net/"
	read -p "(Please input PHP Version you want):" php_version
	if [ "$php_version" = "" ]; then
		echo "Error: You must input php version!!"
		exit 1
	fi

	if [ "$php_version" == "$old_php_version" ]; then
		echo "Error: The upgrade PHP Version is the same as the old Version!!"
		exit 1
	fi
	echo "=================================================="
	echo "You want to upgrade php version to $php_version"
	echo "=================================================="

	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`

echo "============================check files=================================="
if [ -s php-$php_version.tar.gz ]; then
  echo "php-$php_version.tar.gz [found]"
  else
  echo "Error: php-$php_version.tar.gz not found!!!download now......"
  wget -c http://www.php.net/distributions/php-$php_version.tar.gz
  if [ $? -eq 0 ]; then
	echo "Download php-$php_version.tar.gz successfully!"
  else
	echo "WARNING!May be the php version you input was wrong,please check!"
	echo "PHP Version input was:"$php_version
	sleep 5
	exit 1
  fi
fi

if [ -s autoconf-2.69.tar.gz ]; then
  echo "autoconf-2.69.tar.gz [found]"
  else
  echo "Error: autoconf-2.69.tar.gz not found!!!download now......"
  wget -c http://dl.iamle.com/linux/soft/autoconf-2.69.tar.gz
# wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
fi

echo "============================check files=================================="

echo "Stoping PHP-FPM..."
/etc/init.d/php-fpm stop

rm -rf php-$php_version/

tar zxvf autoconf-2.69.tar.gz
cd autoconf-2.69/
./configure --prefix=/usr/local/autoconf-2.69
make && make install
cd ../

ln -s /usr/lib/libevent-1.4.so.2 /usr/local/lib/libevent-1.4.so.2
ln -s /usr/lib/libltdl.so /usr/lib/libltdl.so.3

if [ $php_version = "5.4.27" ] || [ $php_version = "5.3.28" ]; then


sleep 2

#elif [ $php_version = "5.5.12" ]; then
#echo "DO NOT SUPPORT PHP VERSION :$php_version"
#echo "Waiting for script to EXIT......"
#sleep 2
#exit 1

else

#Backup old php version configure files
echo "Backup old php version configure files......"
mkdir -p /root/phpconf
cp /usr/local/php/etc/php-fpm.conf /root/phpconf/php-fpm.conf.old.bak
cp /usr/local/php/etc/php.ini /root/phpconf/php.ini.old.bak
cp /root/lnmp /root/phpconf/lnmp
#rm -f /root/lnmp
/usr/local/php/sbin/php-fpm stop
mv /usr/local/php /usr/local/oldphp
cp /etc/init.d/php-fpm /root/phpconf/php-fpm.old.bak
rm -f /etc/init.d/php-fpm

echo "============================Install PHP $php_version================================"
cd $cur_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.69/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.69/bin/autoheader
tar zxvf php-$php_version.tar.gz
cd php-$php_version/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo --enable-opcache
make ZEND_EXTRA_LIBS='-liconv'
make install

rm -f /usr/bin/php
rm -f /usr/bin/phpize
rm -f /usr/bin/php-fpm

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
cp $cur_dir/php-$php_version/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

cp $cur_dir/lnmp /root/lnmp
chmod +x /root/lnmp
sed -i 's:/usr/local/php/logs:/usr/local/php/var/run:g' /root/lnmp
echo "============================PHP $php_version install completed======================"
echo "Starting PHP-FPM..."
/etc/init.d/php-fpm start


cd $cur_dir
fi
echo "========================================================================="
echo "You have successfully upgrade from $old_php_version to $php_version"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "========================================================================="
fi
