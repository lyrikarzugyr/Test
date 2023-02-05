#!/bin/bash
cpufuzai=$(uptime | awk '{print $12}')
if [ `echo "$cpufuzai>=1.2" |bc` -eq 1 ];then
  echo "cpu负载超过1.2，自动删除节点中!"
  node_count1=`docker ps -a --filter="name=exorde-cli_" | wc -l`
  if [ ${node_count1} = "0" ]; then
#     echo "-----------------------------------------------------"
#     echo "未部署exorde节点,无需删除!"
    all
  else
#     echo "-----------------------------------------------------"
#     echo "当前运行中的exorde节点为: "
#     docker ps --filter="name=exorde-cli_"
    node_count2=`docker ps --filter="name=exorde-cli_" | wc -l`
    for ((i=1; i<=node_count2 - 1; i ++))
      do
        echo "-----------------------------------------------------"
        str1="开始删除exorde节点exorde-cli_"
        str2=${i}
        str3="： "
#         echo ${str1}${str2}${str3}
        docker stop exorde-cli_${i}
        docker rm exorde-cli_${i}
        str4="exorde节点exorde-cli_"
        str5=${i}
        str6="已成功删除!"
#         echo ${str4}${str5}${str6}
        sleep 1
      done 
#     echo "-----------------------------------------------------"
#     echo "开始删除漏网之鱼"
    docker stop $(docker ps --filter="name=exorde-cli_" -q) && docker rm $(docker ps --filter="name=exorde-cli_" -aq)
#     echo "已成功删除漏网之鱼"
#     echo "已彻底删除通过此脚本部署的全部exorde节点!"
#     docker ps

      fi
fi
