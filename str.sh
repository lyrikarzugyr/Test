#!/bin/bash

install_docker(){
        docker_check=`docker version | grep Engine | wc -l`
		if_CentOS8=N
        if [ ${docker_check} = "0" ]; then
            echo "-----------------------------------------------------"
            echo "开始使用Docker官方脚本部署Docker!"
            #read -p "当前版本是否为CentOS8版本(输入Y或N): " if_CentOS8
				curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
				sudo apt-get update
				sudo apt-get install expect -y
        else
            echo "-----------------------------------------------------"
            echo "Docker已安装，无需操作!"
        fi
}

# downloadd_tpm_image() {
        # image_count=`docker image ls | streamrlabs/streamr-prover | wc -l`
        # if [ ${image_count} != "0" ]; then
                # echo "-----------------------------------------------------"
            # echo "已下载专供镜像，无需操作!"
        # else
            # echo "-----------------------------------------------------"
            # echo "开始下载/更新专供streamr最新镜像: "
            # docker pull streamrlabs/streamr-prover:latest
            # echo "-----------------------------------------------------"
            # docker image ls
            # image_count=`docker image ls | grep streamrlabs/streamr-prover | wc -l`
            # if [ ${image_count} != "0" ]; then
                # echo "-----------------------------------------------------"
                # echo "专供streamr最新镜像已下载/更新完成!"
            # else
                # echo "-----------------------------------------------------"
                # echo "镜像下载失败，请确认网络连接正常且正确安装Docker后再重试！"
                # all
            # fi
        # fi
# }

# create_revenue_address() {
        # echo "-----------------------------------------------------"
        # mkdir ${HOME}/streamr && touch ${HOME}/streamr/.revenue_address
        # read -p "请输入ETH收益地址: " ETH_address
        # echo $ETH_address > ${HOME}/streamr/.revenue_address
        # echo "-----------------------------------------------------"
        # echo "已设置ETH收益地址为: "
        # cat ${HOME}/streamr/.revenue_address
# }

# modify_revenue_address() {
        # echo "-----------------------------------------------------"
        # echo "当前设置的ETH收益地址为: "
        # cat ${HOME}/streamr/.revenue_address
        # read -p "是否确认修改该ETH收益地址(输入Y开始修改，输入N取消修改): " modify_file
                # if [ ${modify_file} = "Y" -o ${modify_file} = "y" ]; then
                        # rm ${HOME}/streamr/.revenue_address && touch ${HOME}/streamr/.revenue_address
                        # read -p "请输入新的ETH收益地址: " ETH_address
                                # echo $ETH_address > ${HOME}/streamr/.revenue_address
                                # echo "-----------------------------------------------------"
                                # echo "已设置新的ETH收益地址为: "
                                # cat ${HOME}/streamr/.revenue_address
                # else all
                # fi
# }

deploy_streamrnode() {

		read -p "请输入要部署的节点数量: " node_count
		install_docker
		for ((i=1; i<=node_count; i ++))
		do
				echo "-----------------------------------------------------"
				echo "开始部署streamr节点: "
				private_key='0xf66a3d15a9b5e443fba19d5fa04a686d21ebf875b121ed5b10016b217c34a456'
				websocket_port=$[7170+${i}+${i}-2]
				mqtt_port=$[1883+${i}-1]
				publishHttp_port=$[7171+${i}+${i}-2]
				yinhao='"'
				config_addr=/root/.streamr/broker-config.json
				mkdir $HOME/.streamrDocker_${i}
				cd $HOME/.streamrDocker_${i}
				mv $HOME/.streamrDocker_${i}/broker-config.json $HOME/.streamrDocker_${i}/broker-config.json.bak
				expect << EOF
				set timeout 60
				spawn docker run -it -v $(cd $HOME/.streamrDocker_${i}; pwd):/root/.streamr streamr/broker-node:testnet bin/config-wizard
				expect "Do you want to generate a new Ethereum private key or import an existing one?"
				send "\r"
				expect "We strongly recommend backing up your private key"
				send "y"
				send "\r"
				expect "Select the plugins to enable" 
				send "a\r"
				expect "Provide a port for the websocket Plugin" 
				send "$websocket_port\r"
				expect "Provide a port for the mqtt Plugin" {send "$mqtt_port\r"}
				expect "Provide a port for the publishHttp Plugin" {send "$publishHttp_port\r"}
				expect "Select a path to store the generated config in" {send "$config_addr\r"}
				expect "streamr-broker"
				interact
EOF
				sed -i "s/${yinhao}${websocket_port}${yinhao}/${websocket_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				sed -i "s/${yinhao}${publishHttp_port}${yinhao}/${publishHttp_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				sed -i "s/${yinhao}${mqtt_port}${yinhao}/${mqtt_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				docker create --name streamr_${i} --restart=always -p ${websocket_port}:${websocket_port} -p ${publishHttp_port}:${publishHttp_port} -p ${mqtt_port}:${mqtt_port} -v $(cd $HOME/.streamrDocker_${i}; pwd):/root/.streamr streamr/broker-node:testnet
				docker start streamr_${i}
				echo "-----------------------------------------------------"
				str1="streamr节点streamr_"
				str2=${i}
				str3="已部署完成!"
				echo ${str1}${str2}${str3}
				echo "-----------------------------------------------------"
				sleep 1
		done

}

recovery_streamrnode() {

		read -p "请输入要恢复的节点数量: " node_count
		install_docker
		for ((i=1; i<=node_count; i ++))
		do
				echo "-----------------------------------------------------"
				echo "开始部署streamr节点: "
				read -p "请输入私钥: " private_key
				websocket_port=$[7170+${i}+${i}-2]
				mqtt_port=$[1883+${i}-1]
				publishHttp_port=$[7171+${i}+${i}-2]
				yinhao='"'
				config_addr=/root/.streamr/broker-config.json
				mkdir $HOME/.streamrDocker_${i}
				cd $HOME/.streamrDocker_${i}
				mv $HOME/.streamrDocker_${i}/broker-config.json $HOME/.streamrDocker_${i}/broker-config.json.bak
				expect << EOF
				set timeout 60
				spawn docker run -it -v $(cd $HOME/.streamrDocker_${i}; pwd):/root/.streamr streamr/broker-node:testnet bin/config-wizard
				expect "Do you want to generate a new Ethereum private key or import an existing one?"
				send \0x28
				send "\r"
				expect "Please provide the private key to import" 
				send "$private_key"
				send "\r"
				expect "Select the plugins to enable" 
				send "a\r"
				expect "Provide a port for the websocket Plugin" 
				send "$websocket_port\r"
				expect "Provide a port for the mqtt Plugin" {send "$mqtt_port\r"}
				expect "Provide a port for the publishHttp Plugin" {send "$publishHttp_port\r"}
				expect "Select a path to store the generated config in" {send "$config_addr\r"}
				expect "streamr-broker"
				interact
EOF
				sed -i "s/${yinhao}${websocket_port}${yinhao}/${websocket_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				sed -i "s/${yinhao}${publishHttp_port}${yinhao}/${publishHttp_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				sed -i "s/${yinhao}${mqtt_port}${yinhao}/${mqtt_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				docker create --name streamr_${i} --restart=always -p ${websocket_port}:${websocket_port} -p ${publishHttp_port}:${publishHttp_port} -p ${mqtt_port}:${mqtt_port} -v $(cd $HOME/.streamrDocker_${i}; pwd):/root/.streamr streamr/broker-node:testnet
				docker start streamr_${i}
				echo "-----------------------------------------------------"
				str1="streamr节点streamr_"
				str2=${i}
				str3="已部署完成!"
				echo ${str1}${str2}${str3}
				echo "-----------------------------------------------------"
				sleep 1
		done

}

check_privatekey() {

		read -p "请输入要查询的节点数量: " node_count
		for ((i=1; i<=node_count; i ++))
		do
				address=$(cat $HOME/.streamrDocker_${i}/broker-config.json | grep ethereumPrivateKey)
				echo $address
		done

}




check_publickey() {

		read -p "请输入要查询的节点数量: " node_count
		for ((i=1; i<=node_count; i ++))
		do
				address=$(docker logs streamr_${i} | grep https://streamr.network/network-explorer/nodes)
				echo $address
		done

}

# check_revenue_address() {
        # echo "-----------------------------------------------------"
        # echo "ETH收益地址为: "
        # cat ${HOME}/streamr/.revenue_address
# }

check_streamrnode_status() {
        node_count=`docker ps --filter="name=streamr_" | wc -l`
        if [ ${node_count} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "尚未部署专供streamr节点,请部署后再执行此操作!"
            all
        else
                echo "-----------------------------------------------------"
                echo "当前专供streamr节点运行状态如下: "
                docker ps --filter="name=streamr_"
        fi
}

check_logs_single() {
        node_count=`docker ps --filter="name=streamr_" | wc -l`
        if [ ${node_count} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "尚未部署streamr节点,请部署后再执行此操作!"
            all
        else
                echo "-----------------------------------------------------"
                read -p "请输入要查看的streamr节点序号: " node_number
                read -p "请输入要查看的日志行数: " col_number
                str1="开始查询节点streamr_"
                str2=${node_number}
                str3="日志: "
                echo $str1${str2}$str3
                docker logs --tail ${col_number} streamr_${node_number} 
        fi
}

check_logs_all() {
        node_count=`docker ps --filter="name=streamr_" | wc -l`
        if [ ${node_count} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "尚未部署专供streamr节点,请部署后再执行此操作!"
            all
        else
                read -p "请输入要查看的日志行数: " col_number
                for ((i=1; i<=node_count - 1; i ++))
                do
                echo "-----------------------------------------------------"
                        str1="开始查询节点streamr_"
                        str2=${i}
                        str3="日志: "
                        echo ${str1}${str2}${str3}
                docker logs --tail ${col_number} streamr_${i} 
                sleep 2
                done
        fi
}

# delete_revenue_address() {
        # echo "-----------------------------------------------------"
        # echo "当前设置的ETH收益地址为: "
        # cat ${HOME}/streamr/.revenue_address
        # read -p "是否确认彻底删除该地址文件(输入Y开始删除，输入N取消删除): " delete_file
                # if [ ${delete_file} = "Y" -o ${delete_file} = "y" ]; then
                        # rm -R ${HOME}/streamr
                        # echo "已彻底删除通过此脚本创建的revenue_address文件!"
                # else all
                # fi
# }
delete_streamrnode_all() {
        node_count1=`docker ps -a --filter="name=streamr_" | wc -l`
        if [ ${node_count1} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "未部署streamr节点,无需删除!"
            all
        else
                echo "-----------------------------------------------------"
                echo "当前运行中的专供streamr节点为: "
                docker ps --filter="name=streamr_"
                node_count2=`docker ps --filter="name=streamr_" | wc -l`
                read -p "是否确认彻底删除全部streamr节点(输入Y开始删除，输入N取消删除): " delete_node
                if [ ${delete_node} = "Y" -o ${delete_node} = "y" ]; then
                        for ((i=1; i<=node_count2 - 1; i ++))
                        do
                                echo "-----------------------------------------------------"
                    str1="开始删除streamr节点streamr_"
                    str2=${i}
                    str3="： "
                    echo ${str1}${str2}${str3}
                    docker stop streamr_${i}
                    docker rm streamr_${i}
                    str4="streamr节点streamr_"
                    str5=${i}
                    str6="已成功删除!"
                    echo ${str4}${str5}${str6}
                    sleep 2
                done 
                echo "已彻底删除通过此脚本部署的全部streamr节点!"
                docker ps
            else all
            fi
        fi
}

update_streamrnode() {
		read -p "请输入要更新的节点数量: " node_count
        node_count1=`docker ps -a --filter="name=streamr_" | wc -l`
        if [ ${node_count1} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "未部署streamr节点,无需删除!"
            all
        else
                echo "-----------------------------------------------------"
                echo "当前运行中的专供streamr节点为: "
                docker ps --filter="name=streamr_"
                node_count2=`docker ps --filter="name=streamr_" | wc -l`
                delete_node=Y
                if [ ${delete_node} = "Y" -o ${delete_node} = "y" ]; then
                        for ((i=1; i<=node_count2 - 1; i ++))
                        do
                                echo "-----------------------------------------------------"
                    str1="开始删除streamr节点streamr_"
                    str2=${i}
                    str3="： "
                    echo ${str1}${str2}${str3}
                    docker stop streamr_${i}
                    docker rm streamr_${i}
                    str4="streamr节点streamr_"
                    str5=${i}
                    str6="已成功删除!"
                    echo ${str4}${str5}${str6}
                    sleep 2
                done 
                echo "已彻底删除通过此脚本部署的全部streamr节点!"
                docker ps
            else all
            fi
        fi
		docker pull streamr/broker-node:testnet
		for ((i=1; i<=node_count; i ++))
		do
				echo "-----------------------------------------------------"
				echo "开始部署streamr节点: "
				private_key='0xf66a3d15a9b5e443fba19d5fa04a686d21ebf875b121ed5b10016b217c34a456'
				websocket_port=$[7170+${i}+${i}-2]
				mqtt_port=$[1883+${i}-1]
				publishHttp_port=$[7171+${i}+${i}-2]
				yinhao='"'
				config_addr=/root/.streamr/broker-config.json
				sed -i "s/${yinhao}${websocket_port}${yinhao}/${websocket_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				sed -i "s/${yinhao}${publishHttp_port}${yinhao}/${publishHttp_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				sed -i "s/${yinhao}${mqtt_port}${yinhao}/${mqtt_port}/g" $HOME/.streamrDocker_${i}/broker-config.json
				docker create --name streamr_${i} --restart=always -p ${websocket_port}:${websocket_port} -p ${publishHttp_port}:${publishHttp_port} -p ${mqtt_port}:${mqtt_port} -v $(cd $HOME/.streamrDocker_${i}; pwd):/root/.streamr streamr/broker-node:testnet
				docker start streamr_${i}
				echo "-----------------------------------------------------"
				str1="streamr节点streamr_"
				str2=${i}
				str3="已部署完成!"
				echo ${str1}${str2}${str3}
				echo "-----------------------------------------------------"
				sleep 1
		done

}

# delete_tpm_image() {
        # node_count1=`docker ps -a --filter="name=streamr_" | wc -l`
        # if [ ${node_count1} != "0" ]; then
                # echo "-----------------------------------------------------"
            # echo "以下专供streamr节点尚未删除，请先删除节点后再执行镜像删除操作!"
            # docker ps -a --filter="name=streamr_"
            # all
        # else
                # echo "-----------------------------------------------------"
                # echo "当前运行中的Docker镜像文件为: "
                # docker image ls
                # image_count=`docker image ls | grep streamrlabs/streamr-prover | wc -l`
                # if [ ${image_count} = "0" ]; then
                        # echo "-----------------------------------------------------"
                # echo "尚未下载专供镜像，无需执行次操作!"
                # exit 1
            # else
                # read -p "是否确认彻底删除通过此脚本下载的streamr镜像(输入Y开始删除，输入N取消删除): " delete_image
                # if [ ${delete_image} = "Y" -o ${delete_image} = "y" ]; then
                                # echo "-----------------------------------------------------"
                        # echo "开始删除专供streamr镜像: "
                        # docker rmi streamrlabs/streamr-prover:latest
                        # echo "已彻底删除专供streamr镜像!"
                        # docker image ls
                # else
                        # exit 1
                # fi
            # fi
        # fi
# }

all(){
while true 
        do
cat << EOF

=================================
(1) 安装Docker
(2) 部署streamr节点
(3) 恢复streamr节点
(4) 检查通过此脚本创建的streamr节点运行状态
(5) 查看通过此脚本创建的单个streamr节点运行日志
(6) 查看通过此脚本创建的所有streamr节点运行日志
(7) 删除通过此脚本部署的全部streamr节点
(8) 查询privateKey
(9) 查询publicKey
(10)更新streamr节点
(0) Exit
-----------------------------------------------------
EOF
                read -p "请输入要执行的选项: " input
                case $input in
                        1)
                                echo "安装Docker"
                                install_docker
                                ;;
                        2)
                                echo "部署streamr节点"
                                deploy_streamrnode
                                ;;
						3)
                                echo "恢复streamr节点"
                                recovery_streamrnode
                                ;;
                        4)
                                echo "检查通过此脚本创建的streamr节点运行状态"
                                check_streamrnode_status
                                ;;
                        5)
                                echo "查看通过此脚本创建的单个streamr节点运行日志"
                                check_logs_single
                                ;;
                        6)
                                echo "查看通过此脚本创建的所有streamr节点运行日志"
                                check_logs_all
                                ;;
                        7)
                                echo "删除通过此脚本部署的全部streamr节点"
                                delete_streamrnode_all
                                ;;
						8)
                                echo "查询privateKey"
                                check_privatekey
                                ;;
						9)
                                echo "查询publicKey"
                                check_publickey
                                ;;		
						10)
                                echo "更新streamr节点"
                                update_streamrnode
                                ;;										
                        *)
                                exit 1
                                ;;
                esac

done
}

while true 
        do
cat << EOF
=================================
(1) 安装Docker
(2) 部署streamr节点
(3) 恢复streamr节点
(4) 检查通过此脚本创建的streamr节点运行状态
(5) 查看通过此脚本创建的单个streamr节点运行日志
(6) 查看通过此脚本创建的所有streamr节点运行日志
(7) 删除通过此脚本部署的全部streamr节点
(8) 查询privateKey
(9) 查询publicKey
(10)更新streamr节点
(0) Exit
-----------------------------------------------------
EOF
                read -p "请输入要执行的选项: " input
                case $input in
                        1)
                                echo "安装Docker"
                                install_docker
                                ;;
                        2)
                                echo "部署streamr节点"
                                deploy_streamrnode
                                ;;
						3)
                                echo "恢复streamr节点"
                                recovery_streamrnode
                                ;;
                        4)
                                echo "检查通过此脚本创建的streamr节点运行状态"
                                check_streamrnode_status
                                ;;
                        5)
                                echo "查看通过此脚本创建的单个streamr节点运行日志"
                                check_logs_single
                                ;;
                        6)
                                echo "查看通过此脚本创建的所有streamr节点运行日志"
                                check_logs_all
                                ;;
                        7)
                                echo "删除通过此脚本部署的全部streamr节点"
                                delete_streamrnode_all
                                ;;
						8)
                                echo "查询privateKey"
                                check_privatekey
                                ;;
						9)
                                echo "查询publicKey"
                                check_publickey
                                ;;		
						10)
                                echo "更新streamr节点"
                                update_streamrnode
                                ;;										
                        *)
                                exit 1
                                ;;
                esac

done
