#!/bin/bash

while(true)
	do
#		echo `journalctl -u subspaced -n 1 | grep Waiting`
		if [[ `journalctl -u subspaced -n 1` =~ "Waiting" ]]; then
			sudo systemctl restart farmerd
		fi
		sleep 14
	done
