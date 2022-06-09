#!/bin/bash
read -p "请输入desposit的次数: " count
for ((i=1; i<=count; i ++))
do
		echo 执行第$i次
		expect << EOF
		set timeout 420
		spawn /root/ironfish/ironfish-cli/bin/ironfish deposit  -f 1000 --confirm
#		expect "Do you confirm"
#		send "Y"
#		send "\r"
		expect "Done"
#		interact
EOF
		sleep 60
done
