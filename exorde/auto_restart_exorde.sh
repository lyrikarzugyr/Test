#!/bin/bash

node_count=`docker ps --filter="name=exorde-cli_" | wc -l`
if [ ${node_count} != "0" ]; then
	for ((i=1; i<=node_count - 1; i ++))
	do
	diyihang=$(docker logs exorde-cli_${i} --tail 4 | sed -n '1p')
	disanhang=$(docker logs exorde-cli_${i} --tail 4 | sed -n '3p')
	if [[ $disanhang == "Latest message from Exorde Labs:  IF YOUR REP IS STILL ZERO, PLEASE RESTART THIS WORKER TO TRANSFER REP TO YOUR MAIN ADDRESS. IT WILL WORK. WE ARE NOW MORE RESILIENT WITH DDOS ATTACKS." ]];then
	docker restart exorde-cli_${i}
	fi
	sleep 1
	done
fi
