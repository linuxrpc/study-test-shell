#!/bin/bash
read -p "请输入虚拟机的主机名:" name
read -p "请输入虚拟机的ip:" ip
[ $(df -h | awk '$NF=="/var/ftp/rhel7"{print}' | wc -l) -eq 0 ] && echo "require mount point : /var/ftp/rhel7" && exit 1
virsh destroy ${name} &> /dev/null
virsh undefine ${name} &> /dev/null
rm -rf /var/lib/libvirt/images/${name}.img &> /dev/null


qemu-img create -f qcow2 -b /var/lib/libvirt/images/.rh7_template.img /var/lib/libvirt/images/${name}.img &> /dev/null
cat /var/lib/libvirt/images/.rhel7.xml > /tmp/myvm.xml
sed -i "/<name>rh7_template/s/rh7_template/${name}/" /tmp/myvm.xml
sed -i "/rh7_template\.img/s/rh7_template/${name}/" /tmp/myvm.xml
virsh define /tmp/myvm.xml &> /dev/null
virsh start ${name}
sleep 5
if [ "${ip%.*}" == "192.168.4" ];then
expect <<EO
spawn virsh console ${name}
expect "^]" {send "\r"}
expect "login:" {send "root\r"}
expect "：" {send "123456\r"}
expect "#" {send "ifconfig eth0 ${ip}\r"}
expect "#" {send "hostnamectl set-hostname ${name}\r"}
expect "#" {send "\035"}
expect eof
EO
elif [ "${ip%.*}" == "192.168.2" ];then
echo $ip
expect <<OO
spawn virsh console ${name}
expect "^]" {send "\r"}
expect "login:" {send "root\r"}
expect "：" {send "123456\r"}
expect "#" {send "hostnamectl set-hostname ${name}\r"}
expect "#" {send "ifconfig eth1 ${ip}\r"}
expect "#" {send "\035"}
expect eof
OO
elif [ "${ip%.*}" == "201.1.1" ];then
expect <<EE
spawn virsh console ${name}
expect "^]" {send "\r"}
expect "login:" {send "root\r"}
expect "：" {send "123456\r"}
expect "#" {send "hostnamectl set-hostname ${name}\r"}
expect "#" {send "ifconfig eth2 ${ip}\r"}
expect "#" {send "\035"}
expect eof
EE
elif [ "${ip%.*}" == "201.1.2" ];then
expect <<OE
spawn virsh console ${name}
expect "^]" {send "\r"}
expect "login:" {send "root\r"}
expect "：" {send "123456\r"}
expect "#" {send "hostnamectl set-hostname ${name}\r"}
expect "#" {send "ifconfig eth3 ${ip}\r"}
expect "#" {send "\035"}
expect eof
OE
else
echo "请输入正确的ip"
fi
sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@$ip < yum.sh
sshpass -p 123456 ssh-copy-id root@$ip
