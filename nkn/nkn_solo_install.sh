#!/bin/bash

BENEFIT_ADDRESS = input("请输入收益地址（回车使用默认）:") or "NKNZHPhHmxCJfmGQMwthgsLwXqc1vMrd6sHZ"
NODE_WALLET = input("请输入节点钱包:")
# read -p "请输入收益地址: " BENEFIT_ADDRESS
# read -p "节点钱包: " NODE_WALLET

echo "============================================================================================="
echo "Hardening your OS..."
echo "============================================================================================="
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq upgrade -y
echo "============================================================================================="
echo "Installing necessary libraries..."
echo "============================================================================================="
apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes make curl git unzip whois
apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes ufw
apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes unzip jq
echo "============================================================================================="
echo "Installing NKN Commercial..."
echo "============================================================================================="
wget --quiet --continue --show-progress https://commercial.nkn.org/downloads/nkn-commercial/linux-amd64.zip > /dev/null 2>&1
unzip -qq -o linux-amd64.zip
cd linux-amd64
cat >/root/linux-amd64/config.json <<EOF
{
    "nkn-node": {
      "args": "--sync light",
      "noRemotePortCheck": true
    }
}
EOF
/root/linux-amd64/nkn-commercial -b $BENEFIT_ADDRESS -c /root/linux-amd64/config.json -u root install > /dev/null 2>&1
echo "============================================================================================="
echo "Waiting for wallet generation..."
echo "============================================================================================="
while [ ! -f /root/linux-amd64/services/nkn-node/wallet.json ]; do sleep 10; done
echo "============================================================================================="
echo "Applying finishing touches..."
echo "============================================================================================="
systemctl stop nkn-commercial
echo -n $NODE_WALLET > /root/linux-amd64/services/nkn-node/wallet.json
echo "123456" > /root/linux-amd64/services/nkn-node/wallet.pswd
sleep 10
systemctl restart nkn-commercial
echo "============================================================================================="
