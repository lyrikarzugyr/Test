#!/bin/bash

while(true)
	do
#		echo `journalctl -u subspaced -n 1 | grep Waiting`
		if [[ `journalctl -u subspaced -n 1` =~ "Waiting" ]]; then
			sudo systemctl restart subspaced-farmer
		fi
		sleep 14
	done
