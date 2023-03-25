#!/bin/bash

function setupVars {
	. $HOME/.bash_profile
	if [ ! $EXORDE_WALLET ]; then
		read -p "输入收益钱包地址: " EXORDE_WALLET
		echo 'export EXORDE_WALLET='${EXORDE_WALLET} >> $HOME/.bash_profile
	fi
	echo -e '\n\e[42m你的收益钱包地址:' $EXORDE_WALLET '\e[0m\n'
	echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
	. $HOME/.bash_profile
	sleep 1
}

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


deploy_exordenode() {
		setupVars
		read -p "请输入要部署的节点数量: " node_count
		read -p "请输入cpu限制(输入0.1表示限制10%): " cpu_limit
		install_docker
		for ((i=1; i<=node_count; i ++))
		do
				echo "-----------------------------------------------------"
				echo "开始部署exorde节点: "
				installed_node_flag=`docker ps --filter="name=^/exorde-cli_${i}$" | wc -l`
				if [ $installed_node_flag == 1 ]; then
					docker run -d --restart unless-stopped --pull always --cpus ${cpu_limit} --name exorde-cli_${i} exordelabs/exorde-cli -m ${EXORDE_WALLET} -l 2
				fi
				installed_node_flag=`docker ps --filter="name=^/exorde-cli_${i}$" | wc -l`
				if [ $installed_node_flag == 1 ]; then
					docker run -d --restart unless-stopped --pull always --cpus ${cpu_limit} --name exorde-cli_${i} exordelabs/exorde-cli -m ${EXORDE_WALLET} -l 2
				fi
				echo "-----------------------------------------------------"
				str1="exorde节点exorde-cli_"
				str2=${i}
				str3="已部署完成!"
				echo ${str1}${str2}${str3}
				echo "-----------------------------------------------------"
				sleep 1
		done

}

check_exordenode_status() {
        node_count=`docker ps --filter="name=exorde-cli_" | wc -l`
        if [ ${node_count} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "尚未部署exorde节点,请部署后再执行此操作!"
            all
        else
                echo "-----------------------------------------------------"
                echo "当前exorde节点运行状态如下: "
                docker ps --filter="name=exorde-cli_"
        fi
}

check_logs_single() {
        node_count=`docker ps --filter="name=exorde-cli_" | wc -l`
        if [ ${node_count} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "尚未部署exorde节点,请部署后再执行此操作!"
            all
        else
                echo "-----------------------------------------------------"
                read -p "请输入要查看的exorde节点序号: " node_number
                read -p "请输入要查看的日志行数: " col_number
                str1="开始查询节点exorde-cli_"
                str2=${node_number}
                str3="日志: "
                echo $str1${str2}$str3
                docker logs --tail ${col_number} exorde-cli_${node_number} 
        fi
}

check_logs_all() {
        node_count=`docker ps --filter="name=exorde-cli_" | wc -l`
        if [ ${node_count} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "尚未部署exorde节点,请部署后再执行此操作!"
            all
        else
                read -p "请输入要查看的日志行数: " col_number
                for ((i=1; i<=node_count - 1; i ++))
                do
                echo "-----------------------------------------------------"
                        str1="开始查询节点exorde-cli_"
                        str2=${i}
                        str3="日志: "
                        echo ${str1}${str2}${str3}
                docker logs --tail ${col_number} exorde-cli_${i} 
                sleep 1
                done
        fi
}

delete_exordenode_all() {
        node_count1=`docker ps -a --filter="name=exorde-cli_" | wc -l`
        if [ ${node_count1} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "未部署exorde节点,无需删除!"
            all
        else
                echo "-----------------------------------------------------"
                echo "当前运行中的exorde节点为: "
                docker ps --filter="name=exorde-cli_"
                node_count2=`docker ps --filter="name=exorde-cli_" | wc -l`
                read -p "是否确认彻底删除全部exorde节点(输入Y开始删除，输入N取消删除): " delete_node
                if [ ${delete_node} = "Y" -o ${delete_node} = "y" ]; then
			for ((i=1; i<=node_count2 - 1; i ++))
                        do
				echo "-----------------------------------------------------"
				str1="开始删除exorde节点exorde-cli_"
				str2=${i}
				str3="： "
				echo ${str1}${str2}${str3}
				docker stop exorde-cli_${i}
				docker rm exorde-cli_${i}
				str4="exorde节点exorde-cli_"
				str5=${i}
				str6="已成功删除!"
				echo ${str4}${str5}${str6}
				sleep 1
                	done 
			echo "-----------------------------------------------------"
			echo "开始删除漏网之鱼"
			docker stop $(docker ps --filter="name=exorde-cli_" -q) && docker rm $(docker ps --filter="name=exorde-cli_" -aq)
			echo "已成功删除漏网之鱼"
                echo "已彻底删除通过此脚本部署的全部exorde节点!"
                docker ps
            else all
            fi
        fi
}

update_exordenode() {
		read -p "请输入要更新的节点数量: " node_count
		read -p "请输入cpu限制(输入0.1表示限制10%): " cpu_limit
        node_count1=`docker ps -a --filter="name=exorde-cli_" | wc -l`
        if [ ${node_count1} = "0" ]; then
                echo "-----------------------------------------------------"
            echo "未部署exorde节点,无需删除!"
            all
        else
                echo "-----------------------------------------------------"
                echo "当前运行中的exorde节点为: "
                docker ps --filter="name=exorde-cli_"
                node_count2=`docker ps --filter="name=exorde-cli_" | wc -l`
                delete_node=Y
                if [ ${delete_node} = "Y" -o ${delete_node} = "y" ]; then
                        for ((i=1; i<=node_count2 - 1; i ++))
                        do
                                echo "-----------------------------------------------------"
                    str1="开始删除exorde-cli节点exorde-cli_"
                    str2=${i}
                    str3="： "
                    echo ${str1}${str2}${str3}
                    docker stop exorde-cli_${i}
                    docker rm exorde-cli_${i}
                    str4="exorde节点exorde-cli_"
                    str5=${i}
                    str6="已成功删除!"
                    echo ${str4}${str5}${str6}
                    sleep 2
                done 
		echo "开始删除漏网之鱼"
		docker stop $(docker ps --filter="name=exorde-cli_" -q) && docker rm $(docker ps --filter="name=exorde-cli_" -aq)
		echo "已成功删除漏网之鱼"
                echo "已彻底删除通过此脚本部署的全部exorde节点!"
                docker ps
            else all
            fi
        fi
		docker rm $(docker ps -a -q)
		docker rmi $(docker images -q)
		setupVars
		install_docker
		for ((i=1; i<=node_count; i ++))
		do
				echo "-----------------------------------------------------"
				echo "开始部署exorde节点: "
				installed_node_flag=`docker ps --filter="name=^/exorde-cli_${i}$" | wc -l`
				if [ $installed_node_flag == 1 ]; then
					docker run -d --restart unless-stopped --pull always --cpus ${cpu_limit} --name exorde-cli_${i} exordelabs/exorde-cli -m ${EXORDE_WALLET} -l 2
				fi
				installed_node_flag=`docker ps --filter="name=^/exorde-cli_${i}$" | wc -l`
				if [ $installed_node_flag == 1 ]; then
					docker run -d --restart unless-stopped --pull always --cpus ${cpu_limit} --name exorde-cli_${i} exordelabs/exorde-cli -m ${EXORDE_WALLET} -l 2
				fi
				echo "-----------------------------------------------------"
				str1="exorde节点exorde-cli_"
				str2=${i}
				str3="已部署完成!"
				echo ${str1}${str2}${str3}
				echo "-----------------------------------------------------"
				sleep 1
		done

}

all(){
while true 
        do
cat << EOF
=================================
(1) 安装Docker
(2) 部署exorde节点
(3) 检查通过此脚本创建的exorde节点运行状态
(4) 查看通过此脚本创建的单个exorde节点运行日志
(5) 查看通过此脚本创建的所有exorde节点运行日志
(6) 删除通过此脚本部署的全部exorde节点
(7) 更新exorde节点
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
                                echo "部署exorde节点"
                                deploy_exordenode
                                ;;
                        3)
                                echo "检查通过此脚本创建的exorde节点运行状态"
                                check_exordenode_status
                                ;;
                        4)
                                echo "查看通过此脚本创建的单个exorde节点运行日志"
                                check_logs_single
                                ;;
                        5)
                                echo "查看通过此脚本创建的所有exorde节点运行日志"
                                check_logs_all
                                ;;
                        6)
                                echo "删除通过此脚本部署的全部exorde节点"
                                delete_exordenode_all
                                ;;
						7)
                                echo "更新exorde节点"
                                update_exordenode
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
(2) 部署exorde节点
(3) 检查通过此脚本创建的exorde节点运行状态
(4) 查看通过此脚本创建的单个exorde节点运行日志
(5) 查看通过此脚本创建的所有exorde节点运行日志
(6) 删除通过此脚本部署的全部exorde节点
(7) 更新exorde节点
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
                                echo "部署exorde节点"
                                deploy_exordenode
                                ;;
                        3)
                                echo "检查通过此脚本创建的exorde节点运行状态"
                                check_exordenode_status
                                ;;
                        4)
                                echo "查看通过此脚本创建的单个exorde节点运行日志"
                                check_logs_single
                                ;;
                        5)
                                echo "查看通过此脚本创建的所有exorde节点运行日志"
                                check_logs_all
                                ;;
                        6)
                                echo "删除通过此脚本部署的全部exorde节点"
                                delete_exordenode_all
                                ;;
						7)
                                echo "更新exorde节点"
                                update_exordenode
                                ;;										
                        *)
                                exit 1
                                ;;
                esac

done
