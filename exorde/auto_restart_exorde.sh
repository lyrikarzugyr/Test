#!/bin/bash

node_count=`docker ps --filter="name=exorde-cli_" | wc -l`
if [ ${node_count} != "0" ]; then
	for ((i=1; i<=node_count - 1; i ++))
	do
	diyihang=$(docker logs exorde-cli_${i} --tail 4 | sed -n '1p')
	disanhang=$(docker logs exorde-cli_${i} --tail 4 | sed -n '3p')
	if [[ $diyihang == "[UPDATE SYSTEM] Checking new updates..." ]];then
	if [[ $disanhang == "[UPDATE SYSTEM] Checking new updates..." ]];then
	docker restart exorde-cli_${i}
	fi
	fi
	sleep 1
	done
fi
