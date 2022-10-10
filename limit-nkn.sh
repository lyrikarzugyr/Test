#!/bin/bash
cpufuzai=$(uptime | awk '{print $12}')
npoolfuzai=$(ps aux | awk '{if($11=="/root/linux-amd64/npool") print$3}')
cpulimitflag=$(ps -ef | awk '{if($8=="cpulimit" && $10=="npool" && $12=="10") print$1}')
if [[ $cpulimitflag == root ]];then
if [ `echo "$npoolfuzai>=3" |bc` -eq 1 ];then
if [ `echo "$cpufuzai<=0.2" |bc` -eq 1 ];then
kill -9 $(ps -ef | awk '{if($8=="cpulimit" && $10=="npool" && $12=="10") print$2}')
echo -e "\n" | nohup cpulimit --exe npool --limit 15 >/dev/null 2>&1 &
else
if [ `echo "$cpufuzai>=0.35" |bc` -eq 1 ];then
kill -9 $(ps -ef | awk '{if($8=="cpulimit" && $10=="npool" && $12=="10") print$2}')
echo -e "\n" | nohup cpulimit --exe npool --limit 5 >/dev/null 2>&1 &
fi
fi
fi
fi
cpulimitflag=$(ps -ef | awk '{if($8=="cpulimit" && $10=="npool" && $12=="5") print$1}')
if [[ $cpulimitflag != root ]];then
if [ `echo "$cpufuzai>=0.35" |bc` -eq 1 ];then
kill -9 $(ps -ef | awk '{if($8=="cpulimit" && $10=="npool" && $12=="15") print$2}')
echo -e "\n" | nohup cpulimit --exe npool --limit 10 >/dev/null 2>&1 &
fi
fi
