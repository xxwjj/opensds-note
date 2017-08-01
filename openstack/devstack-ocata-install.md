# devstack ocata 版本安装方法 #

## 环境信息
* ubuntu 16.04
* python2.7
## 安装步骤

### 创建stack user
* 创建stack用户

		sudo useradd -s /bin/bash -d /opt/stack -m stack
* 添加sudo权限

		echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
		sudo su - stack

### 设置apt源
vim /etc/apt/source.list 替换成如下配制

	deb http://cn.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse
	deb http://cn.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse
	deb http://cn.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse
	deb http://cn.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
	deb http://cn.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse
	deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse
	deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse
	deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse
	deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
	deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse
	deb http://archive.canonical.com/ubuntu/ xenial partner

运行命令更新
	sudo apt-get update

### 安装git
	sudo apt-get install git

### 下载devstack 切换到ocata版本
* 方法1  

    	git clone http://git.trystack.cn/openstack-dev/devstack.git -b stable/ocata  

* 方法2

    	git clone https://github.com/openstack-dev/devstack.git 
    	cd devstack/;git branch -a
    	git checkout -b mitaka  origin/stable/ocata


### 安装pip
devstack 安装pip有问题，可以直接通过命令下载，并copy到对应的目录

	wget  https://bootstrap.pypa.io/get-pip.py
	cp get-pip.py /home/devstack/files/

### 设置pip 源 需要分别配制 `/root/.pip/pip.conf` `/home/stack/.pip/pip.conf`

	[global]
	index-url = http://mirrors.aliyun.com/pypi/simple/
	trusted-host=mirrors.aliyun.com

### 配置local.conf文件

	cd devstack
	vim local.conf

local.conf 文件配制如下，需要修改相应该的IP

	[[local|localrc]]
	
	# use TryStack git mirror
	GIT_BASE=http://git.trystack.cn
	NOVNC_REPO=http://git.trystack.cn/kanaka/noVNC.git
	SPICE_REPO=http://git.trystack.cn/git/spice/spice-html5.git
	
	#OFFLINE=True
	RECLONE=True
	
	# Define images to be automatically downloaded during the DevStack built process.
	DOWNLOAD_DEFAULT_IMAGES=False
	IMAGE_URLS="http://images.trystack.cn/cirros/cirros-0.3.4-x86_64-disk.img"
	
	HOST_IP=10.5.11.51
	
	
	# Credentials
	DATABASE_PASSWORD=pass
	ADMIN_PASSWORD=pass
	SERVICE_PASSWORD=pass
	SERVICE_TOKEN=pass
	RABBIT_PASSWORD=pass
	
	HORIZON_BRANCH=stable/ocata
	KEYSTONE_BRANCH=stable/ocata
	NOVA_BRANCH=stable/ocata
	NEUTRON_BRANCH=stable/ocata
	GLANCE_BRANCH=stable/ocata
	CINDER_BRANCH=stable/ocata
	
	
	#keystone
	KEYSTONE_TOKEN_FORMAT=UUID
	
	##Heat
	HEAT_BRANCH=stable/ocata
	enable_service h-eng h-api h-api-cfn h-api-cw
	
	
	## Swift
	SWIFT_BRANCH=stable/ocata
	ENABLED_SERVICES+=,s-proxy,s-object,s-container,s-account
	SWIFT_REPLICAS=1
	SWIFT_HASH=011688b44136573e209e
	
	
	# Enabling Neutron (network) Service
	disable_service n-net
	enable_service q-svc
	enable_service q-agt
	enable_service q-dhcp
	enable_service q-l3
	enable_service q-meta
	enable_service q-metering
	enable_service neutron
	
	## ceilometer
	enable_service ceilometer ceilometer-acompute ceilometer-acentral ceilometer-anotification ceilometer-collector ceilometer-api
	
	## Neutron options
	Q_USE_SECGROUP=True
	FLOATING_RANGE="10.5.0.0/16"
	FIXED_RANGE="10.5.0.0/16"
	Q_FLOATING_ALLOCATION_POOL=start=10.5.11.55,end=10.5.11.200
	PUBLIC_NETWORK_GATEWAY="10.5.255.254"
	Q_L3_ENABLED=True
	PUBLIC_INTERFACE=eth0
	Q_USE_PROVIDERNET_FOR_PUBLIC=True
	OVS_PHYSICAL_BRIDGE=br-ex
	PUBLIC_BRIDGE=br-ex
	OVS_BRIDGE_MAPPINGS=public:br-ex
	
	# #VLAN configuration.
	Q_PLUGIN=ml2
	ENABLE_TENANT_VLANS=True
	
	# Logging
	LOGFILE=/opt/stack/logs/stack.sh.log
	VERBOSE=True
	LOG_COLOR=True
	SCREEN_LOGDIR=/opt/stack/logs

### 启动devstack

	./stack

### 用法
设置环境变量

	source openrc admin admin
	source openrc demo demo

## 参考
https://docs.openstack.org/devstack/latest/

http://blog.csdn.net/qiqishuang/article/details/51990662

http://blog.csdn.net/debo0531/article/details/71452945?locationNum=2&fps=1

