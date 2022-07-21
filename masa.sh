#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}

service_exists() {
    local n=$1
    if [[ $(systemctl list-units --all -t service --full --no-legend "$n.service" | sed 's/^\s*//g' | cut -f1 -d' ') == $n.service ]]; then
        return 0
    else
        return 1
    fi
}







function setupVars {
	. $HOME/.bash_profile
	if [ ! $NODE_NAME ]; then
		read -p "Enter node name: " NODE_NAME
		echo 'export NODE_NAME='${NODE_NAME} >> $HOME/.bash_profile
	fi
	echo -e '\n\e[42mYour node name:' $NODE_NAME '\e[0m\n'

	. $HOME/.bash_profile
	echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
	. $HOME/.bash_profile
	sleep 1
}

function setupSwap {
	echo -e '\n\e[42mSet up swapfile\e[0m\n'
	curl -s https://api.nodes.guru/swap4.sh | bash
}

function installSoftware {

	sudo apt install apt-transport-https net-tools git mc sysstat atop curl tar wget clang pkg-config libssl-dev jq build-essential make ncdu -y
	
	cd ~
	wget --inet4-only "https://golang.org/dl/go1.17.5.linux-amd64.tar.gz"
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf "go1.17.5.linux-amd64.tar.gz"
	rm "go1.17.5.linux-amd64.tar.gz"
	echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.profile
	source ~/.profile
	
	git clone https://github.com/masa-finance/masa-node-v1.0
	cd masa-node-v1.0/src
	make all
	
	cp /root/masa-node-v1.0/src/build/bin/* /usr/local/bin
	
	source ~/.profile
	cd $HOME/masa-node-v1.0
	geth --datadir data init ./network/testnet/genesis.json
	
}


function installService {
echo -e '\n\e[42mRunning\e[0m\n' && sleep 1
echo -e '\n\e[42mCreating a service\e[0m\n' && sleep 1

tee /etc/systemd/system/masad.service > /dev/null <<EOF
[Unit]
Description=MASA
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/geth \\
--identity ${NODE_NAME} \\
--datadir /root/masa-node-v1.0/data \\
--bootnodes "enode://7612454dd41a6d13138b565a9e14a35bef4804204d92e751cfe2625648666b703525d821f34ffc198fac0d669a12d5f47e7cf15de4ebe65f39822a2523a576c4@81.29.137.40:30300" \\
--emitcheckpoints \\
--istanbul.blockperiod 10 \\
--mine \\
--miner.threads 1 \\
--syncmode full \\
--verbosity 5 \\
--networkid 190260 \\
--rpc \\
--rpccorsdomain "*" \\
--rpcvhosts "*" \\
--rpcaddr 127.0.0.1 \\
--rpcport 8545 \\
--rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul \\
--port 30300
Restart=on-failure
RestartSec=10
LimitNOFILE=4096
Environment="PRIVATE_CONFIG=ignore"
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1
sudo systemctl enable masad
sudo systemctl restart masad
sed -i.bak -e "s/.*SystemMaxUse=.*/SystemMaxUse=1000M/" /etc/systemd/journald.conf
sed -i.bak -e "s/.*ForwardToSyslog=.*/ForwardToSyslog=no/" /etc/systemd/journald.conf
systemctl restart systemd-journald.service


echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service masad status | grep active` =~ "running" ]]; then
  echo -e "Your Masa node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice masad status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Masa node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
. $HOME/.bash_profile
}



function updateSoftware {

systemctl stop masad
. ~/.profile
find ~/masa-node-v1.0/data/geth/* -type f -not -name 'nodekey' -delete
rm -f ~/masa-node-v1.0/src/build/bin/*
cd ~/masa-node-v1.0
git pull

cd ~/masa-node-v1.0/src 
make all 

cp -f /root/masa-node-v1.0/src/build/bin/* /usr/local/bin

source ~/.profile
cd $HOME/masa-node-v1.0
geth --datadir data init ./network/testnet/genesis.json

. $HOME/.bash_profile

tee /etc/systemd/system/masad.service > /dev/null <<EOF
[Unit]
Description=MASA
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/geth \\
--identity ${NODE_NAME} \\
--datadir /root/masa-node-v1.0/data \\
--bootnodes "enode://7612454dd41a6d13138b565a9e14a35bef4804204d92e751cfe2625648666b703525d821f34ffc198fac0d669a12d5f47e7cf15de4ebe65f39822a2523a576c4@81.29.137.40:30300" \\
--emitcheckpoints \\
--istanbul.blockperiod 10 \\
--mine \\
--miner.threads 1 \\
--syncmode full \\
--verbosity 5 \\
--networkid 190260 \\
--rpc \\
--rpccorsdomain "*" \\
--rpcvhosts "*" \\
--rpcaddr 127.0.0.1 \\
--rpcport 8545 \\
--rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul \\
--port 30300
Restart=on-failure
RestartSec=10
LimitNOFILE=4096
Environment="PRIVATE_CONFIG=ignore"
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload 
sudo systemctl enable masad 
sudo systemctl restart masad 
echo "[Journal]" > /etc/systemd/journald.conf
echo "Storage=persistent" >> /etc/systemd/journald.conf
echo "SystemMaxUse=1000M" >> /etc/systemd/journald.conf
echo "ForwardToSyslog=no" >> /etc/systemd/journald.conf
chmod 644 /etc/systemd/journald.conf
systemctl restart systemd-journald.service
}


function backupNodekey {
	cp /root/masa-node-v1.0/data/geth/nodekey ~/
	echo "$(<~/nodekey)"
}







PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Upgrade" "Backup nodekey" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
            echo -e '\n\e[42mYou choose install...\e[0m\n' && sleep 1
			setupVars
			setupSwap
			installSoftware
			installService
			break
            ;;
        "Upgrade")
            echo -e '\n\e[33mYou choose upgrade...\e[0m\n' && sleep 1
			setupVars
			updateSoftware
			#installListener
			echo -e '\n\e[33mYour node was upgraded!\e[0m\n' && sleep 1
			break
            ;;
		"Backup nodekey")
			echo -e '\n\e[33mYou choose backup nodekey...\e[0m\n' && sleep 1
			backupNodekey
			echo -e '\n\e[33mYour nodekey was saved in $HOME/nodekey !\e[0m\n' && sleep 1
			break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done
