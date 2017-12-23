# ceph 环境搭建 #
ceph 可以通过ceph-deploy搭建，也可以直接通过docker来安装

## 通过docker 来搭建

	mkdir -p /etc/ceph
	docker run -d --net=host -v /etc/ceph:/etc/ceph -e MON_IP=172.17.0.1 -e CEPH_PUBLIC_NETWORK=172.17.0.0/24 ceph/demo --name ceph
	#注：如果需要重启ceph 容器，需要把/etc/ceph配制文件删除。

## 通过 ceph-deploy 搭建
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

启动ceph osd时，系统找不到命令ceph-disk-prepare和ceph-disk-activate，需要更改执行的指令：
	
	ceph-disk -v prepare --fs-type xfs --cluster ceph -- /srv/ceph/osd0
	ceph-disk -v activate --mark-init upstart --mount /srv/ceph/osd3

### 目前机器重启会导致ceph无法使用，可参考如下步骤解决
* 在每个osd节点执行

		losetup /dev/loop1 /home/ceph.img
		mount /dev/loop1 /srv/ceph/osd0/
* 在主机节上执行

		ceph-deploy osd activate opensds-worker-1:/srv/ceph/osd0

### ceph-deploy install 报错： bash: python: command not found
	安装python
	apt-get install python2.7 -y
	ln -s /usr/bin/python2.7 /usr/bin/python

## ceph 常用命令
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
	ceph osd in osd.0 # 把osd加进集群
### pool
* 创建

```
ceph osd pool create rbd 128
ceph osd pool set rbd size 1
```
* 查看
```
ceph df
ceph osds lspools
ceph osd pool ls detail
rados df
rados lspools
```
* 删除

```
ceph 删除pool
1. 修改配制文件/etc/ceph/ceph.conf。
mon allow pool delete = true
添加到[global] section里面。
2. 重启ceph-mon。
service ceph-mon restart
3. 查看修改是否成功。
ceph -n mon.1 --show-config | grep mon_allow_pool_delete
4. 删除
ceph osd pool delete rbd rbd  --yes-i-really-really-mean-it
```
### image
	rbd ls
	rbd info imagename
	rbd create imagesname --size 1M

### map
	rbd map imagesname
	rbd showmapped
	rbd unmap

### snap

	rbd snap ls imagename
	rbd snap rm imagename:snapname
	rbd snap create imagename@snapname
	rbd snap purge # 删除所有关于指定卷的快照


### 问题
### 可能出现内核不有加载ceph ko的情况
	# 查询
	lsmod | grep ceph
	lsmod | grep rbd
	# 加载
	modprobe ceph
	moprobe rbd


### rbd map报错：mon0 192.168.0.1:6789 feature set mismatch
* 解决方法：ceph osd crush tunables legacy  
* 如果想要一劳永逸，可以在 vi /etc/ceph/ceph.conf 中加入 rbd_default_features = 1 来设置默认 features(数值仅是 layering 对应的 bit 码所对应的整数值)。


### 集群状态 为HEATL_ERR
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

##参考文档
https://github.com/ceph/ceph-container
