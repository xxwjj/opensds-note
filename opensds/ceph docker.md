### ceph docker 安装方法：
```
mkdir -p /etc/ceph
docker run -d --net=host -v /etc/ceph:/etc/ceph -e MON_IP=172.17.0.1 -e CEPH_PUBLIC_NETWORK=172.17.0.0/24 ceph/demo
```
### ceph 快照相关命令
``` bash
rbd snap ls imagename
rbd snap rm imagename:snapname
rbd snap create imagename@snapname
rbd snap purge # 删除所有关于指定卷的快照
```
### 参考文档

https://github.com/ceph/ceph-container
