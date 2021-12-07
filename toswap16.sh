#!/bin/bash
echo -e '\n\e[42m[Swap] Starting...\e[0m\n'
sudo swapoff -a
sed -i 's//root/swapfile swap swap defaults 0 0//g' /etc/fstab
cd $HOME
sudo fallocate -l 16G $HOME/swapfile
sudo dd if=/dev/zero of=swapfile bs=1K count=16M
sudo chmod 600 $HOME/swapfile
sudo mkswap $HOME/swapfile
sudo swapon $HOME/swapfile
sudo swapon --show
echo $HOME'/swapfile swap swap defaults 0 0' >> /etc/fstab
echo -e '\n\e[42m[Swap] Done\e[0m\n'