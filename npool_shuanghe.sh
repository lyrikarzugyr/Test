#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}


read -p "请输入npool的key: " NPOOL_KEY

#关闭自动更新
sudo apt remove unattended-upgrades -y

#关闭日志
echo "[Journal]" > /etc/systemd/journald.conf
echo "Storage=none" >> /etc/systemd/journald.conf
chmod 644 /etc/systemd/journald.conf
systemctl restart systemd-journald.service

#安装npool主程序
cd ~ && wget -c https://download.npool.io/npool.sh -O npool.sh&& sudo chmod +x npool.sh && sudo ./npool.sh $NPOOL_KEY

#安装npool数据库
# cd /root/linux-amd64
# systemctl stop npool.service
# rm -rf ChainDB
# wget -c -O - https://down.npool.io/ChainDB.tar.gz  | tar -xzf -


#启动npool
#sleep 259200
systemctl restart npool.service
cd ~

#安装cpulimit+关一核
sudo apt update
apt install -y cpulimit
echo -e "\n" | nohup cpulimit --exe systemd-journald --limit 5 >/dev/null 2>&1 &
str=$"\n"
sstr=$(echo -e $str)
echo $sstr
# echo 0 > /sys/devices/system/cpu/cpu1/online


# 运行auto_restart_npool.sh脚本
# cd ~ && wget -q -O auto_restart_npool.sh https://raw.githubusercontent.com/lyrikarzugyr/Test/main/npool/auto_restart_npool.sh && chmod +x auto_restart_npool.sh && echo -e "\n" | nohup /bin/bash auto_restart_npool.sh >/dev/null 2>&1 &

echo -e "Npool节点\e[32m安装成功\e[39m!"

