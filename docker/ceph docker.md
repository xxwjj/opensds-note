### 清理环境：
	docker stop mon
	docker rm mon
	docker stop myosd1
	docker rm myosd1
	rm /etc/ceph/* -rf
	rm /var/lib/ceph/*  -rf

### 启动容器 172.17.0.1为宿主机IP。
	sudo docker run -d --net=host --name=mon \
	-v /etc/ceph:/etc/ceph \
	-v /var/lib/ceph/:/var/lib/ceph \
	-e MON_IP=172.17.0.1 \
	-e CEPH_PUBLIC_NETWORK=172.17.0.0/16 \
	ceph/daemon mon

### 查看日志：
	docker logs -f mon

### 启动osd1
	mkfs.xfs -f /dev/loop1
	sudo docker run -d --net=host --name=myosd1 \
	--privileged=true \
	-v /etc/ceph:/etc/ceph \
	-v /var/lib/ceph/:/var/lib/ceph \
	-v /dev/:/dev/ \
	-e OSD_DEVICE=/dev/loop1 \
	ceph/daemon osd_ceph_disk