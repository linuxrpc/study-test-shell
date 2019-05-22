#!/bin/bash
YUM () { rm -rf /etc/yum.repos.d/*
echo  "[rpc]
name=rpc
baseurl=$1
enabled=1
gpgcheck=0" > /etc/yum.repos.d/rpc.repo
yum clean all  &> /dev/null
n=`yum repolist | awk '/repolist/{print $2}' | sed 's/,//g'`
if [ $n -eq 0 ];then
	echo "yum搭建失败"
else
	echo "yum搭建成功"
fi
}
sed -i '/^SELINUX/s/permissive/disabled/' /etc/selinux/config 
ip=$(ifconfig | awk '$1=="inet" && $2 != "127.0.0.1"{print $2}' | sed -n '{1p}')
if [ "${ip%.*}" == "192.168.4" ];then
	nmcli connection modify eth0 ipv4.method manual ipv4.addresses ${ip}/24 connection.autoconnect yes
	nmcli connection up eth0
	YUM ftp://192.168.4.254/rhel7
elif [ "${ip%.*}" == "192.168.2" ];then
	nmcli connection modify eth1 ipv4.method manual ipv4.addresses  ${ip}/24 connection.autoconnect yes
	nmcli connection up eth1
	YUM ftp://192.168.2.254/rhel7
elif [ "${ip%.*}" == "201.1.1" ];then
	nmcli connection modify eth2 ipv4.method manual ipv4.addresses  ${ip}/24 connection.autoconnect yes
	nmcli connection up eth2
	YUM ftp://201.1.1.254/rhel7
elif [ "${ip%.*}" == "201.1.2" ];then
	nmcli connection modify eth3 ipv4.method manual ipv4.addresses  ${ip}/24 connection.autoconnect yes
	nmcli connection up eth3
	YUM ftp://201.1.2.254/rhel7
else
	echo "ip地址获取失败"
fi
