# k8s && ceph 安装

## k8s 搭建

###	设置hosts，打开vim /etc/hosts

    45.76.69.84     opensds-master
	45.77.69.39     opensds-worker-1
	45.32.83.131    opensds-worker-2
	104.238.141.111 opensds-worker-3

### 下载并安装 golang
	wget https://storage.googleapis.com/golang/go1.7.6.linux-amd64.tar.gz
	tar xvf go1.7.6.linux-amd64.tar.gz -C /usr/local/
	mkdir -p $HOME/gopath/src
	mkdir -p $HOME/gopath/bin
	echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/gopath/bin' >> /etc/profile
	echo 'export GOPATH=$HOME/gopath' >> /etc/profile
	source /etc/profile
	go version #查看是否安装正确

### 创建 log 日志文件路

	mkdir /var/log/k8s -p
	mkdir /var/log/etcd -p
	mkdir /var/lib/etcd/ -p
	mkdir /var/log/flannel -p

### 下载etcd并安装


    wget https://github.com/coreos/etcd/releases/download/v3.2.0/etcd-v3.2.0-linux-amd64.tar.gz
	tar xvf etcd-v3.2.0-linux-amd64.tar.gz
    cp etcd-v3.2.0-linux-amd64/etcd* /usr/local/bin

### 启动etcd


	nohup etcd -name infra1 -initial-advertise-peer-urls http://45.76.69.84:2380 -listen-peer-urls http://45.76.69.84:2380 -listen-client-urls http://45.76.69.84:2379,http://127.0.0.1:2379 -advertise-client-urls http://45.76.69.84:2379 -initial-cluster-token etcd-cluster -initial-cluster infra1=http://45.76.69.84:2380,infra2=http://45.77.69.39:2380,infra3=http://45.32.83.131:2380,infra4=http://104.238.141.111:2380 -initial-cluster-state new --data-dir /var/lib/etcd/data  &>> /var/log/etcd/etcd.log &
	nohup etcd -name infra2 -initial-advertise-peer-urls http://45.77.69.39:2380 -listen-peer-urls http://45.77.69.39:2380 -listen-client-urls http://45.77.69.39:2379,http://127.0.0.1:2379 -advertise-client-urls http://45.77.69.39:2379 -initial-cluster-token etcd-cluster -initial-cluster infra1=http://45.76.69.84:2380,infra2=http://45.77.69.39:2380,infra3=http://45.32.83.131:2380,infra4=http://104.238.141.111:2380 -initial-cluster-state new --data-dir /var/lib/etcd/data  &>> /var/log/etcd/etcd.log &	
	nohup etcd -name infra3 -initial-advertise-peer-urls http://45.32.83.131:2380 -listen-peer-urls http://45.32.83.131:2380 -listen-client-urls http://45.32.83.131:2379,http://127.0.0.1:2379 -advertise-client-urls http://45.32.83.131:2379 -initial-cluster-token etcd-cluster -initial-cluster infra1=http://45.76.69.84:2380,infra2=http://45.77.69.39:2380,infra3=http://45.32.83.131:2380,infra4=http://104.238.141.111:2380 -initial-cluster-state new --data-dir /var/lib/etcd/data  &>> /var/log/etcd/etcd.log &	
	nohup etcd -name infra4 -initial-advertise-peer-urls http://104.238.141.111:2380 -listen-peer-urls http://104.238.141.111:2380 -listen-client-urls http://104.238.141.111:2379,http://127.0.0.1:2379 -advertise-client-urls http://104.238.141.111:2379 -initial-cluster-token etcd-cluster -initial-cluster infra1=http://45.76.69.84:2380,infra2=http://45.77.69.39:2380,infra3=http://45.32.83.131:2380,infra4=http://104.238.141.111:2380 -initial-cluster-state new --data-dir /var/lib/etcd/data  &>> /var/log/etcd/etcd.log &

### 查看安装是etcdctl cluster状态
	etcdctl cluster-health

### 用法
	# 查看所有以api为前缀的值
	ETCDCTL_API=3 etcdctl get /api --prefix=true
	# 删除所有以api为前缀的值
	ETCDCTL_API=3 etcdctl del /api --prefix=true

### 下载并安装flannel
	wget https://github.com/coreos/flannel/releases/download/v0.8.0-rc1/flannel-v0.8.0-rc1-linux-amd64.tar.gz
	mkdir flannel
	tar xvf flannel-v0.8.0-rc1-linux-amd64.tar.gz -C flannel/
	cp flannel/flanneld /usr/local/bin/
	cp flannel/mk-docker-opts.sh /usr/local/bin/


### 在etcd中写入docker子网信息：
	ETCDCTL_API=2 etcdctl set /coreos.com/network/config '{ "Network": "172.17.0.0/16" }'

### 启动flannel：
	nohup flanneld &>> /var/log/flannel/flanneld.log &
	如果有多张网卡需要指定网卡：
	nohup flanneld -iface enp0s8 &>> /var/log/flanneld.log &

### 安装docker
* 方法1：  
	```wget -qO- https://get.docker.com/ | sh```

* 方法2：  
	```apt-get install docker.io```


### 修改docker启动参数：
	mk-docker-opts.sh -i
	source /run/flannel/subnet.env
	rm /var/run/docker.pid
	ifconfig docker0 ${FLANNEL_SUBNET}


修改  
	
	ifconfig
	#/etc/default/docker
	DOCKER_OPTS="--bip 172.17.77.1/24"  
重启  

	service docker restart


用ifconfig 查看 docker ip是否已经更改，如果没有请参考作如下修改

```vim /lib/systemd/system/docker.service  ```  
增加：  
```EnvironmentFile=-/etc/default/docker    ```  
修改：  
```ExecStart=/usr/bin/docker -d -H fd://   ```==>```ExecStart=/usr/bin/docker -d -H fd:// $DOCKER_OPTS```  

### 下载k8s 1.5

	wget https://github.com/kubernetes/kubernetes/archive/release-1.5.zip

### 解压 编译k8s
	unzip release-1.5.zip 
	apt-get install libc-dev gcc make
	cd kubernetes-release-1.5/;make
### 启动K8S master进程：


	nohup kube-apiserver --insecure-bind-address=0.0.0.0 --insecure-port=8080 --service-cluster-ip-range='10.254.0.1/24' --log_dir=/var/log/kube --kubelet_port=10250 --v=0 --logtostderr=false --etcd_servers=http://45.76.69.84:2379 --allow_privileged=true &>> /var/log/kube/kube-apiserver.log  &	
	nohup kube-controller-manager  --v=0 --logtostderr=false --log_dir=/var/log/kube --master=45.76.69.84:8080 &>> /var/log/kube/kube-controller-manager &	
	nohup kube-scheduler  --master='45.76.69.84:8080' --v=0  --log_dir=/var/log/kube  &>> /var/log/kube/kube-scheduler.log &
	

kubectl get componentstatuses


### 启动K8S worknode进程：

	nohup kubelet --logtostderr=false --v=0 --allow-privileged=false  --log_dir=/var/log/kube  --address=0.0.0.0  --port=10250  --hostname_override=45.77.69.39 --api_servers=http://45.76.69.84:8080  &>> /var/log/kube/kube-kubelet.log &	
	nohup kube-proxy  --logtostderr=false --v=0 --master=http://45.76.69.84:8080  &>> /var/log/kube/kube-proxy.log &

	kubelet --volume-plugin-dir=/root/plugins/

#### K8S跨节点容器网络不通解决方法：
集群中，数据包从flannel0不转发给docker0，导致跨节点的容器不能通信，需要在worknode打开系统的iptables转发：

	iptables -P FORWARD ACCEPT

#### 预先下载pause镜像

	docker pull kubernetes/pause
	docker tag kubernetes/pause gcr.io/google_containers/pause-amd64:3.0


### 端口转发

	nohup socat tcp-listen:80,reuseaddr,fork tcp:192.168.56.102:80 &
	nohup socat tcp-listen:8080,reuseaddr,fork tcp:192.168.56.102:8080 &
	nohup socat tcp-listen:8443,reuseaddr,fork tcp:192.168.56.102:8443 &
	nohup socat tcp-listen:4443,reuseaddr,fork tcp:192.168.56.102:4443 &
	nohup socat tcp-listen:7443,reuseaddr,fork tcp:192.168.56.102:7443 &


## Ceph搭建
**注：** opensds-worker-1 为节点主机名，ceph-deploy会通过主机名访问,因些需要的hosts设置主机名和ip的映射关系。
### 创建loop 块

	cd /home/
	dd if=/dev/zero of=/home/ceph.img bs=1GB count=10
	losetup /dev/loop1 /home/ceph.img 

### 挂载块

	mkdir -p /srv/ceph/osd0/
	mkfs.xfs -f /dev/loop1
	mount /dev/loop1 /srv/ceph/osd0/

### 安装 ceph-deploy
	
	apt-get install ceph-deploy


### 生成配制文件

	mkdir ceph-cluster
	cd ceph-cluster
	ceph-deploy new  opensds-worker-1


如果是单节点：

	echo "osd crush chooseleaf type = 0" >> ceph.conf
	echo "osd pool default size = 1" >> ceph.conf
	echo "osd journal size = 100" >> ceph.conf

### 安装mon 和osd

	ceph-deploy install opensds-worker-1
	ceph-deploy mon create opensds-worker-1
	ceph-deploy gatherkeys opensds-worker-1
	ceph-deploy osd prepare opensds-worker-1:/srv/ceph/osd0
	chown -R ceph:ceph /srv/ceph/osd0/
	ceph-deploy osd activate opensds-worker-1:/srv/ceph/osd0

### 问题
#### 启动ceph osd时，系统找不到命令ceph-disk-prepare和ceph-disk-activate，需要更改执行的指令：

	
	ceph-disk -v prepare --fs-type xfs --cluster ceph -- /srv/ceph/osd0
	ceph-disk -v activate --mark-init upstart --mount /srv/ceph/osd3

### 查看监控集群状态:
	ceph health
	ceph status
	ceph osd stat
	ceph osd dump
	ceph osd tree
	ceph mon dump
	ceph quorum_status
	ceph mds stat
	ceph mds dump

### ceph 常用命令
	rbd create imagesname --size 1M
	rbd ls
	rbd map imagesname
	rbd showmapped
	rbd unmap
### 可能出现内核不有加载ceph ko的情况
	# 查询
	lsmod | grep ceph
	lsmod | grep rbd
	# 加载
	modprobe ceph
	moprobe rbd

### 报错解决方案
#### rbd map报错：mon0 192.168.0.1:6789 feature set mismatch
* 解决方法：ceph osd crush tunables legacy  
* 如果想要一劳永逸，可以在 vi /etc/ceph/ceph.conf 中加入 rbd_default_features = 1 来设置默认 features(数值仅是 layering 对应的 bit 码所对应的整数值)。

#### ceph-deploy install 报错： bash: python: command not found
	安装python
	apt-get install python2.7 -y
	ln -s /usr/bin/python2.7 /usr/bin/python

#### 集群状态 为HEATL_ERR
ceph -s 出现如下错误


	root@opensds-worker-1:/var/log/ceph# ceph -s
	    cluster 60445850-b6b2-4fad-8651-fed96bfff9c3
	     health HEALTH_ERR
	            64 pgs are stuck inactive for more than 300 seconds
	            64 pgs degraded
	            64 pgs stuck degraded
	            64 pgs stuck inactive
	            64 pgs stuck unclean
	            64 pgs stuck undersized
	            64 pgs undersized
	     monmap e1: 1 mons at {opensds-worker-1=192.168.56.101:6789/0}
	            election epoch 4, quorum 0 opensds-worker-1
	     osdmap e8: 1 osds: 1 up, 1 in
	            flags sortbitwise,require_jewel_osds
	      pgmap v61: 64 pgs, 1 pools, 0 bytes data, 0 objects
	            5152 MB used, 4373 MB / 9526 MB avail
	                  64 undersized+degraded+peered

`ps -ef|grep ceph` 查看发现有个节点并没有启动osd,后面用 `ceph-deploy osd activate opensds-worker-2:/srv/ceph/osd0 ` 启动即可



## flex-plugin && flex-provisioner
	go get github.com/leonwanghui/opensds-k8s/cmd/flex-plugin/opensds
	go install github.com/leonwanghui/opensds-k8s/cmd/flex-plugin/opensds
	mkdir -p /usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds/
	#copy 需要重启kubelet
	cp $GOPATH/bin/opensds /usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds
	scp $GOPATH/bin/opensds opensds-worker-1:/usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds
	scp $GOPATH/bin/opensds opensds-worker-2:/usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds
	scp $GOPATH/bin/opensds opensds-worker-3:/usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds
	cd $GOPATH/src/github.com/leonwanghui/opensds-k8s/vendor/github.com/kubernetes-incubator/external-storage/flex
	make && make container

	docker save quay.io/kubernetes_incubator/flex-provisioner | ssh opensds-worker-1 -C "docker load"
	docker save quay.io/kubernetes_incubator/flex-provisioner | ssh opensds-worker-2 -C "docker load"
	docker save quay.io/kubernetes_incubator/flex-provisioner | ssh opensds-worker-3 -C "docker load"

## k8s 单节点测试环境方法
	wget https://github.com/coreos/etcd/releases/download/v3.2.0/etcd-v3.2.0-linux-amd64.tar.gz
	tar xvf etcd-v3.2.0-linux-amd64.tar.gz
    cp etcd-v3.2.0-linux-amd64/etcd* /usr/local/bin
	wget https://github.com/kubernetes/kubernetes/archive/release-1.5.zip
	unzip release-1.5.zip
	cd kubernetes-release-1.6/hack/
	./local-up-cluster.sh

	echo 'export GOPATH=/root/gopath' >> /etc/profile
	echo 'export PATH=/usr/local/go/bin/:$PATH' >> /etc/profile
	echo 'export PATH=$PATH:$GOPATH/bin >> /etc/profile
	echo "export PATH=`pwd`:$PATH" >> /etc/profile
	ln -s kubectl.sh kubectl
	source /etc/profile

## os-brick 
### 安装
	curl https://bootstrap.pypa.io/get-pip.py | python
	apt-get install python-dev
	pip install git+https://github.com/leonwanghui/os-brick.git
### 配制
	
	cp /usr/local/etc/os-brick/ /etc/ -r
	vi /etc/os-brick/os-brick.conf

	[DEFAULT]
	my_ip=your_host_ip

	mkdir -p /var/log/os-brick/
	nohup os-brick-api --config-file /etc/os-brick/os-brick.conf &>> /var/log/os-brick/os-brick.conf &

## 安装opensds
### 下载编译
	apt-get install librbd-dev librados-dev

	go install github.com/opensds/opensds/cmd/osdsdock
	go install github.com/opensds/opensds/cmd/osdslet
	
	mkdir -p $HOME/gopath/bin
	echo 'export GOPATH=$HOME/gopath' >> /etc/profile
	echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/gopath/bin' >> /etc/profile
	. /etc/profile

	scp $HOME/gopath/bin/osds* opensds-worker-1:/$HOME/gopath/bin
	scp $HOME/gopath/bin/osds* opensds-worker-2:/$HOME/gopath/bin
	scp $HOME/gopath/bin/osds* opensds-worker-3:/$HOME/gopath/bin

### 启动
* master

		mkdir /etc/opensds
		mkdir /var/log/opensds
		cp $HOME/gopath/src/github.com/opensds/opensds/examples/*.json /etc/opensds/
		nohup osdslet --endpoint=192.168.56.100:50040 &>> /var/log/opensds/osdslet-api.log &

* worker

		nohup osdsdock &>> /dev/null &

* 宿主机
	
	nohup socat tcp-listen:50040,reuseaddr,fork tcp:192.168.56.100:50040 &

### 测试
#### profile
list

	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/profiles | python -m json.tool

show

	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/profiles/cff92323-06e0-40c1-82c0-d49f20539c15 | python -m json.tool

create

	
	curl -X POST -H "Content-Type: application/json"  \
	http://192.168.56.100:50040/api/v1alpha1/block/profiles -d \
	'{
	    "spec": {
	        "name": "default",
	        "description": "default policy"
	    }
	}' | python -m json.tool

delete

	curl -X DELETE  http://192.168.56.100:50040/api/v1alpha1/block/profiles/0337b89b-1b0c-4608-9297-df9d91d3495e


#### volume
list

	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/volumes | python -m json.tool

show

	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/volumes/81d909ee-6f3a-4d57-9bb4-7aab830d26ff | python -m json.tool

create

	curl -X POST -H "Content-Type: application/json"  \
	http://192.168.56.100:50040/api/v1alpha1/block/volumes -d \
	'{
	    "spec": {
	        "name": "vol001",
	        "description": "test vol",
	        "size": 1
	    }
	}'| python -m json.tool

delete

	curl -X DELETE  http://192.168.56.100:50040/api/v1alpha1/block/volumes/0ff19ed4-5ae6-4a88-bff2-1c3bcff442ec -d '{"spec":{}}' | python -m json.tool

#### snapshots
	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/snapshots| python -m json.tool
	

### helm 安装
	curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get｜bash

## 参考链接：
http://www.linuxidc.com/Linux/2016-01/127784.htm  
https://docs.docker.com/engine/installation/linux/ubuntu/  
http://www.linuxdiyf.com/linux/18428.html  
http://cephnotes.ksperis.com/blog/2014/01/21/feature-set-mismatch-error-on-ceph-kernel-client/
https://mritd.me/2017/05/27/ceph-note-1/
https://my.oschina.net/renguijiayi/blog/293317?p=1


