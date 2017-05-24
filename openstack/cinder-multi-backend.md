### 配置ceph为cinder的backend

#### 在ceph节点上创建pool

```
ceph osd pool create volumes 128
```

#### copy配制文件到cinder volume节点
```
ssh {your-openstack-server} sudo tee /etc/ceph/ceph.conf </etc/ceph/ceph.conf
```
#### 安装rbd的python库和ceph client端
```
sudo apt-get install python-rbd
sudo apt-get install ceph-common
```
#### 配制cinder的权限
```
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rwx pool=images'
```

#### 生成配制文件并修改权限
```
ceph auth get-or-create client.cinder | ssh {your-volume-server} sudo tee /etc/ceph/ceph.client.cinder.keyring
ssh {your-cinder-volume-server} sudo chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring
```

#### 修改/etc/cinder/cinder.conf配制文件
```
[DEFAULT]
...
enabled_backends = ceph
...
[ceph]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
volume_backend_name = ceph
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
glance_api_version = 2
```

#### 重启cinder
```
sudo service cinder-volume restart
```

### 设置backend为multi-backend


#### 修改配制文件 /etc/cinder/cinder.conf

```
enabled_backends=lvm
[lvm]
volume_driver=cinder.volume.drivers.lvm.LVMISCSIDriver
volume_backend_name=lvm
[ceph]
volume_driver=cinder.volume.drivers.rbd.RBDDriver
volume_backend_name=ceph
```
配制完成后需要重新cinder-volume
#### 创建volume type

```
cinder type-create lvm
cinder type-key lvm set volume_backend_name=lvm

cinder type-create ceph
cinder type-key ceph set volume_backend_name=ceph

cinder extra-specs-list (just to check the settings are there)
```

#### 创建卷
```
cinder create --name lvm --volume-type lvm 1
```


### 参考文档

http://docs.ceph.com/docs/master/rbd/rbd-openstack/  
https://wiki.openstack.org/wiki/Cinder-multi-backend
