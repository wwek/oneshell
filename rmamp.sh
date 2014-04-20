#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cat << EOF
+--------------------------------------------------------------+
| === Remove Bin apache(httpd),mysql,php === |
+--------------http://www.iamle.com------------------------+
+----------------------Author:wwek--------------------------+
EOF

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root"
    exit 1
fi

#Remove Bin apache(httpd),mysql,php

function RmampRemove()
{
    rpm -qa|grep httpd
    rpm -e httpd
    rpm -qa|grep mysql
    rpm -e mysql
    rpm -qa|grep php
    rpm -e php

    yum -y remove httpd*
    yum -y remove php*
    yum -y remove mysql-server mysql
    yum -y remove php-mysql

    yum -y install yum-fastestmirror
    yum -y remove httpd
}
RmampRemove 2>&1 | tee /tmp/rmampRemove.log
