#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}



read -p "请输入npool的key: " NPOOL_KEY


#关闭日志
echo "[Journal]" > /etc/systemd/journald.conf
echo "Storage=none" >> /etc/systemd/journald.conf
chmod 644 /etc/systemd/journald.conf
systemctl restart systemd-journald.service

#安装cpulimit+关一核
apt install -y cpulimit
echo -e "\n" | nohup cpulimit --exe systemd-journald --limit 5 >/dev/null 2>&1 &
str=$"\n"
sstr=$(echo -e $str)
echo $sstr
echo 0 > /sys/devices/system/cpu/cpu1/online

#安装npool主程序
cd ~ && wget https://download.npool.io/npool.sh && sudo chmod +x npool.sh && sudo ./npool.sh $NPOOL_KEY

#安装npool数据库
cd /root/linux-amd64
systemctl stop npool.service
rm -rf ChainDB
wget -O - https://download.npool.io/ChainDB.tar.gz  | tar -xzf -
systemctl restart npool.service
cd ~


echo -e "Npool节点\e[32m安装成功\e[39m!"

