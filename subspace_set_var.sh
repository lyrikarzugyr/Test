#!/bin/bash
if [ ! $NODE_NAME ]; then
	read -p "Enter node name: " NODE_NAME
	echo 'export SUBSPACE_NODENAME='${NODE_NAME} >> $HOME/.bash_profile
fi
if [ ! $WALLET_ADDRESS ]; then
	read -p "Enter wallet address: " WALLET_ADDRESS
	echo 'export SUBSPACE_WALLET='${WALLET_ADDRESS} >> $HOME/.bash_profile
fi
