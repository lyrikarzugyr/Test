#!/bin/bash

while true
do
  #获取uptime最后一个字段（15分钟负载）
  cpufuzai=$(uptime | awk '{print $NF}')

  # 如果负载>=1.2则重启npool
  if [ `echo "$cpufuzai>=1.1" |bc` -eq 1 ];then
    systemctl restart npool
  fi
  # sleep60分钟
  sleep 3600
done


