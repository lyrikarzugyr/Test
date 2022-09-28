#API地址https://github.com/koalalorenzo/python-digitalocean
import digitalocean
token = input("请输入token: ") or "未输入"

#查询账户信息
def chaxun_account(token):
	manager = digitalocean.Manager(token=token)
	account = manager.get_account()
	print("账号邮箱："+ str(account.email) + "\n账号配额限制："+ str(account.droplet_limit))



#查询云主机信息
def chaxun_droplets(token):
	manager = digitalocean.Manager(token=token)
	my_droplets = manager.get_all_droplets()
	i=1
	for droplet in my_droplets:
		print("第【" + str(i) + "】台----" + str(droplet) + "----" + str(droplet.ip_address))
		i=i+1

#删除主机
def shanchu_droplets(token):
	manager = digitalocean.Manager(token=token)
	my_droplets = manager.get_all_droplets()
	i=1
	for droplet in my_droplets:
		print("正在删除第【" + str(i) + "】台----" + str(droplet) + "----" + str(droplet.ip_address))
		i=i+1
		droplet.destroy()
	print("删除主机完成")


#创建主机
def chuangjian_droplets(token,region,size_slug,password,number):
	user_data = "#!/bin/bash\necho 'root:" + password + "' | chpasswd"
	number = int(number)
	for i in range(1,number+1):
		name = "ubuntu-" + size_slug + "-" + region + "-" + str(i)
		
		droplet = digitalocean.Droplet(token=token,
		name=name,
		region=region,
		image='ubuntu-20-04-x64',
		size_slug=size_slug,
		ipv6=True,
		backups=False,
		user_data=user_data)
		droplet.create()
		print("第" + str(i) + "台创建完成")
	
#查看可选地区
def chaxun_region(token):
	manager = digitalocean.Manager(token=token)
	regions = manager.get_all_regions()
	for region in regions:
		print(region)
		
#查看可选镜像
def chaxun_size(token):	
	manager = digitalocean.Manager(token=token)
	sizes = manager.get_all_sizes()
	for size in sizes:
		print(size)


if __name__ == '__main__':

	while True:
		flag = input("请输入要执行的程序:（1：查询账号信息，2：查询主机信息，3：删除全部主机，4：创建主机，5：查看可选地区，6：查看可选镜像） ") or "0"
		if (flag=="0"):
			break
		if (flag=="1"):
			chaxun_account(token)
		if (flag=="2"):
			chaxun_droplets(token)
		if (flag=="3"):
			shanchu_droplets(token)
		if (flag=="4"):
			number = input("请输入创建台数:") or "1"
			region = input("请输入地区（默认sfo3）:") or "sfo3"
			size_slug = input("请输入配置(默认s-4vcpu-8gb)") or "s-4vcpu-8gb"
			password = input("请输入密码(默认***********)") or "Qz1308!@#Qz"
			chuangjian_droplets(token,region,size_slug,password,number)
		if (flag=="5"):
			chaxun_region(token)
		if (flag=="6"):
			chaxun_size(token)
