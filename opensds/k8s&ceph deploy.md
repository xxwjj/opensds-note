# k8s && ceph 安装

## k8s 搭建

### 下载etcd并安装启动etcd
``` bash
nohup etcd -name infra1 -initial-advertise-peer-urls http://192.168.0.9:2380 -listen-peer-urls http://192.168.0.9:2380 -listen-client-urls http://192.168.0.9:2379,http://127.0.0.1:2379 -advertise-client-urls http://192.168.0.9:2379 时间-initial-cluster-token etcd-cluster -initial-cluster infra1=http://192.168.0.9:2380,infra2=http://192.168.0.13:2380,infra3=http://192.168.0.14:2380,infra4=http://192.168.0.15:2380 -initial-cluster-state new --data-dir /usr/local/kubernete_test/flanneldata  >> /usr/local/kubernete_test/logs/etcd.log 2>&1 &


nohup etcd -name infra2 -initial-advertise-peer-urls http://192.168.0.13:2380 -listen-peer-urls http://192.168.0.13:2380 -listen-client-urls http://192.168.0.13:2379,http://127.0.0.1:2379 -advertise-client-urls http://192.168.0.13:2379 -initial-cluster-token etcd-cluster -initial-cluster infra1=http://192.168.0.9:2380,infra2=http://192.168.0.13:2380,infra3=http://192.168.0.14:2380,infra4=http://192.168.0.15:2380 -initial-cluster-state new --data-dir /usr/local/kubernete_test/flanneldata  >> /usr/local/kubernete_test/logs/etcd.log 2>&1 &


nohup etcd -name infra3 -initial-advertise-peer-urls http://192.168.0.14:2380 -listen-peer-urls http://192.168.0.14:2380 -listen-client-urls http://192.168.0.14:2379,http://127.0.0.1:2379 -advertise-client-urls http://192.168.0.14:2379 -initial-cluster-token etcd-cluster -initial-cluster infra1=http://192.168.0.9:2380,infra2=http://192.168.0.13:2380,infra3=http://192.168.0.14:2380,infra4=http://192.168.0.15:2380 -initial-cluster-state new --data-dir /usr/local/kubernete_test/flanneldata  >> /usr/local/kubernete_test/logs/etcd.log 2>&1 &


nohup etcd -name infra4 -initial-advertise-peer-urls http://192.168.0.15:2380 -listen-peer-urls http://192.168.0.15:2380 -listen-client-urls http://192.168.0.15:2379,http://127.0.0.1:2379 -advertise-client-urls http://192.168.0.15:2379 -initial-cluster-token etcd-cluster -initial-cluster infra1=http://192.168.0.9:2380,infra2=http://192.168.0.13:2380,infra3=http://192.168.0.14:2380,infra4=http://192.168.0.15:2380 -initial-cluster-state new --data-dir /usr/local/kubernete_test/flanneldata  >> /usr/local/kubernete_test/logs/etcd.log 2>&1 &
```

### 在etcd种写入docker子网信息：
```
etcdctl set /coreos.com/network/config '{ "Network": "172.17.0.0/16" }'
```

### 启动flannel：
```
nohup flanneld >> /usr/local/kubernete_test/logs/flanneld.log 2>&1 &
```

### 修改docker启动参数：
```
mk-docker-opts.sh -i
source /run/flannel/subnet.env
rm /var/run/docker.pid
ifconfig docker0 ${FLANNEL_SUBNET}
```

修改
```
/etc/default/docker: DOCKER_OPTS="--bip 172.17.77.1/24"  
``` 

重启
```
docker   service docker restart
```

### 启动K8S master进程：

```
nohup kube-apiserver --insecure-bind-address=0.0.0.0 --insecure-port=8080 --service-cluster-ip-range='10.254.0.1/24' --log_dir=/usr/local/kubernete_test/logs/kube --kubelet_port=10250 --v=0 --logtostderr=false --etcd_servers=http://192.168.0.9:2379 --allow_privileged=true >> /usr/local/kubernete_test/logs/kube-apiserver.log 2>&1 &


nohup kube-controller-manager  --v=0 --logtostderr=false --log_dir=/usr/local/kubernete_test/logs/kube --master=192.168.0.9:8080 >> /usr/local/kubernete_test/logs/kube-controller-manager 2>&1 &


nohup kube-scheduler  --master='192.168.0.9:8080' --v=0  --log_dir=/usr/local/kubernete_test/logs/kube  >> /usr/local/kubernete_test/logs/kube-scheduler.log 2>&1 &


kubectl get componentstatuses
```

### 启动K8S worknode进程：

```
nohup kubelet --logtostderr=false --v=0 --allow-privileged=false  --log_dir=/usr/local/kubernete_test/logs/kube  --address=0.0.0.0  --port=10250  --hostname_override=192.168.0.13 --api_servers=http://192.168.0.9:8080  >> /usr/local/kubernete_test/logs/kube-kubelet.log 2>&1 &

nohup kube-proxy  --logtostderr=false --v=0 --master=http://192.168.0.9:8080  >> /usr/local/kubernete_test/logs/kube-proxy.log 2>&1 &
```

```
kubelet --volume-plugin-dir=/root/plugins/
```


#### K8S跨节点容器网络不通解决方法：
集群中，数据包从flannel0不转发给docker0，导致跨节点的容器不能通信，需要在worknode打开系统的iptables转发：
```
iptables -P FORWARD ACCEPT
```
#### 预先下载pause镜像
```
docker pull kubernetes/pause
docker tag kubernetes/pause gcr.io/google_containers/pause-amd64:3.0
```

### 端口转发
```
nohup socat tcp-listen:80,reuseaddr,fork tcp:192.168.56.102:80 &
nohup socat tcp-listen:8080,reuseaddr,fork tcp:192.168.56.102:8080 &
nohup socat tcp-listen:8443,reuseaddr,fork tcp:192.168.56.102:8443 &
nohup socat tcp-listen:4443,reuseaddr,fork tcp:192.168.56.102:4443 &
nohup socat tcp-listen:7443,reuseaddr,fork tcp:192.168.56.102:7443 &
```

## Ceph搭建

### 挂载块
```
mkdir -p /srv/ceph/osd0/
mkfs.xfs -f /dev/xvdb
mount /dev/xvdb /srv/ceph/osd0/
```
### 安装 ceph-deploy
```
apt-get install ceph-deploy
```

### 生成配制文件
```
mkdir ceph-cluster
cd ceph-cluster
ceph-deploy new  ecs-storage-0001
```

如果是单节点：
```
echo "osd crush chooseleaf type = 0" >> ceph.conf
echo "osd pool default size = 1" >> ceph.conf
echo "osd journal size = 100" >> ceph.conf
```
### 安装mon 和osd
```
ceph-deploy install ecs-storage-0001
ceph-deploy mon create ecs-storage-0001
ceph-deploy gatherkeys ecs-storage-0001
ceph-deploy osd prepare ecs-storage-0001:/srv/ceph/osd0
ceph-deploy osd activate ecs-storage-0001:/srv/ceph/osd0
```

启动ceph osd时，系统找不到命令ceph-disk-prepare和ceph-disk-activate，需要更改执行的指令：

```
ceph-disk -v prepare --fs-type xfs --cluster ceph -- /srv/ceph/osd0
ceph-disk -v activate --mark-init upstart --mount /srv/ceph/osd3
```

rbd map报错：mon0 192.168.0.1:6789 feature set mismatch
解决方法：ceph osd crush tunables legacy




## 参考链接：
http://www.linuxidc.com/Linux/2016-01/127784.htm  
https://docs.docker.com/engine/installation/linux/ubuntu/  
http://www.linuxdiyf.com/linux/18428.html  
http://cephnotes.ksperis.com/blog/2014/01/21/feature-set-mismatch-error-on-ceph-kernel-client/



