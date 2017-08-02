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
	
	# If the ``*_PASSWORD`` variables are not set here you will be prompted to enter
	# values for them by ``stack.sh``and they will be added to ``local.conf``.
	ADMIN_PASSWORD=admin
	DATABASE_PASSWORD=admin
	RABBIT_PASSWORD=admin
	SERVICE_PASSWORD=$ADMIN_PASSWORD
	
	# Neither is set by default.
	HOST_IP=192.168.56.104
	#HOST_IPV6=2001:db8::7
	
	# path of the destination log file.  A timestamp will be appended to the given name.
	LOGFILE=$DEST/logs/stack.sh.log
	
	# Old log files are automatically removed after 7 days to keep things neat.  Change
	# the number of days by setting ``LOGDAYS``.
	LOGDAYS=2
	
	HEAT_BRANCH=stable/ocata
	ENABLED_SERVICES+=,heat,h-api,h-api-cfn,h-api-cw,h-eng
	enable_service h-eng h-api h-api-cfn h-api-cw
	#Enable heat plugin
	enable_plugin heat http://git.trystack.cn/openstack/heat stable/ocata
	IMAGE_URL_SITE="http://download.fedoraproject.org"
	IMAGE_URL_PATH="/pub/fedora/linux/releases/25/CloudImages/x86_64/images/"
	IMAGE_URL_FILE="Fedora-Cloud-Base-25-1.3.x86_64.qcow2"
	IMAGE_URLS+=","$IMAGE_URL_SITE$IMAGE_URL_PATH$IMAGE_URL_FILE
	
	# Using stable/ocata branches
	# ---------------------------------
	
	# Uncomment these to grab the stable/ocata branches from the
	# repos:
	CINDER_BRANCH=stable/ocata
	GLANCE_BRANCH=stable/ocata
	HORIZON_BRANCH=stable/ocata
	KEYSTONE_BRANCH=stable/ocata
	KEYSTONECLIENT_BRANCH=stable/ocata
	NOVA_BRANCH=stable/ocata
	NOVACLIENT_BRANCH=stable/ocata
	NEUTRON_BRANCH=stable/ocata
	SWIFT_BRANCH=stable/ocata
	
	# Swift is now used as the back-end for the S3-like object store. Setting the
	# hash value is required and you will be prompted for it if Swift is enabled
	# so just set it to something already:
	SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
	
	# For development purposes the default of 3 replicas is usually not required.
	# Set this to 1 to save some resources:
	SWIFT_REPLICAS=1
	
	# The data for Swift is stored by default in (``$DEST/data/swift``),
	# or (``$DATA_DIR/swift``) if ``DATA_DIR`` has been set, and can be
	# moved by setting ``SWIFT_DATA_DIR``. The directory will be created
	# if it does not exist.
	SWIFT_DATA_DIR=$DEST/data


### 启动devstack

	./stack

### 用法
设置环境变量

	source openrc admin admin
	source openrc demo demo

### 设置镜像源
由于网络问题 cirros-0.3.4-x86_64-uec.tar.gz , Fedora-Cloud-Base-25-1.3.x86_64.qcow2 可能会出现下载超导致Devstack失败，可以手动先重官网下载好，放入相应的路径下面

	wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-uec.tar.gz -O cirros-0.3.4-x86_64-uec.tar.gz

	wget http://download.fedoraproject.org/pub/fedora/linux/releases/25/CloudImages/x86_64/images/Fedora-Cloud-Base-25-1.3.x86_64.qcow2

## 参考

https://docs.openstack.org/heat/latest/getting_started/on_devstack.html  
https://docs.openstack.org/devstack/latest/  
http://blog.csdn.net/qiqishuang/article/details/51990662  
http://blog.csdn.net/debo0531/article/details/71452945?locationNum=2&fps=1

