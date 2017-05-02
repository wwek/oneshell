#!/bin/bash
rpm -qa|grep kernel |grep -Ev $(uname -a|awk '{print $3}') |xargs yum remove -y
