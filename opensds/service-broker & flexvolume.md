# OpenSDS service-broker and FlexVolume show #

## 操作步骤

#### 安装cfssl
安装 
go get -u github.com/cloudflare/cfssl/cmd/...

echo $GOPATH
/usr/local

ls /usr/local/bin/cfssl*
cfssl cfssl-bundle cfssl-certinfo cfssljson cfssl-newkey cfssl-scan

### 启动k8s

* 修改 hack/local-up-cluster.sh 在ADMISSION_CONTROL添加PodPreset
```
ADMISSION_CONTROL=Initializers,NamespaceLifecycle,LimitRanger,ServiceAccount${security_admission},DefaultStorageClass,DefaultTolerationSeconds,GenericAdmissionWebhook,ResourceQuota,PodPreset
```
* 启动k8s
```
RUNTIME_CONFIG=settings.k8s.io/v1alpha1=true AUTHORIZATION_MODE=Node,RBAC hack/local-up-cluster.sh -O
```
RUNTIME_CONFIG 为了让k8s api支持podpreset  
AUTHORIZATION_MODE 为了让k8s支持service-catalog

### 生成service-broker Docker镜像

cd nbp/service-broker
go build .
docker build . -t service-broker:v1alpha

### 生成FlexVolume插件

```bash
cd nbp/flexvolume/cmd/flex-plugin
go build  -o opensds .
mkdir -p /usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds
cp nbp/flexvolume/cmd/flex-plugin/opensds /usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds
```

###  添加catalog仓库(需要翻墙)
```bash
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com
helm search service-catalog
```
### 初始化helm
```bash
helm init
kubectl get pod -n kube-system
```
### 设置权限
```bash
kubectl create clusterrolebinding tiller-cluster-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:default
```
### 安装catalog
```bash
helm install svc-cat/catalog \
    --name catalog --namespace catalog

kubectl get pod -n catalog
```

### 安装 service-broker
```bash
helm install charts/ --name service-broker --namespace service-broker
kubectl get pod -n service-broker
```
### 查询brokers,classes,bindings
```bash
kubectl get clusterservicebrokers,clusterserviceclasses,serviceinstances,servicebindings
```
### 创建 service-broker
```bash
kubectl create -f examples/service-broker.yaml
kubectl get clusterservicebrokers,clusterserviceclasses,clusterserviceplans
```
### 创建namespace
```bash
kubectl create ns opensds
```
### 创建instance
```bash
kubectl create -f examples/service-instance.yaml -n opensds
kubectl get serviceinstances -n opensds -o yaml
```
### bindings
```bash
kubectl create -f examples/service-binding.yaml -n opensds
 
kubectl get servicebindings -n opensds -o yaml

kubectl describe  servicebindings -n opensds
```
### secrets
```bash
kubectl get secrets -n opensds

kubectl get secrets service-binding -o yaml -n opensds

kubectl get secrets service-binding -o yaml -n opensds | grep volumeId | awk  '{print $2}' | base64 -d && echo
```

### 修改podpreset的volume name 并创建PodPreset
```
vi examples/podpreset-preset.yaml
kubectl create -f examples/podpreset-preset.yaml 
kubectl get podpreset
```
yaml文件
```yaml
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: allow-database
spec:
  selector:
    matchLabels:
      role: frontend
  volumeMounts:
    - mountPath: /mnt/wordpress
      name: 938b481a-af44-44e4-9cc0-e13ac5c0cc5e
  volumes:
    - name: 938b481a-af44-44e4-9cc0-e13ac5c0cc5e
      flexVolume:
        driver: "opensds.io/opensds"
        fsType: "ext4"
```


### 创建WrodPress 服务和端口转发
```
kubectl create -f examples/Wordpress.yaml

socat tcp-listen:8084,reuseaddr,fork tcp:10.0.0.124:8084
```
yaml文件
```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress
spec:
  template:
    metadata:
      labels:
        app: wordpress
        role: frontend
    spec:
      containers:
      - name: wordpress
        image: wordpress:latest
        imagePullPolicy: IfNotPresent
        ports:
        - name: wordpress
          containerPort: 8084
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress
spec:
  type: ClusterIP
  ports:
  - name: wordpress
    port: 8084
    targetPort: 8084
    protocol: TCP
  selector:
    app: wordpress
```

### 清理
### 删除
```bash
kubectl delete -f examples/podpreset-preset.yaml 

kubectl delete -f examples/Wordpress.yaml

kubectl delete -n opensds  servicebindings service-binding

kubectl delete -n opensds serviceinstances service-instance

kubectl delete clusterservicebrokers service-broker

helm delete --purge service-broker

kubectl delete ns opensds service-broker
```

### iscsi相关命令
#### taget
```
tgtadm --lld iscsi --op show --mode target
tgtadm --lld iscsi --op delete --mode logicalunit --tid 1 --lun 15
tgtadm --lld iscsi --op bind --mode target --tid=1 -I ALL
```

#### initiator
```
iscsiadm --mode discovery --type sendtargets --portal 192.168.56.103:3260
iscsiadm -m node -p 192.168.56.103:3260 -T iqn.2017-10.io.opensds:volume:00000001 --logout
iscsiadm -m node -p 192.168.56.103:3260 -T iqn.2017-10.io.opensds:volume:00000001 --login
```

###其它
#### 删除所有的容器 
```docker ps -a | sed '1d'|awk '{print $1}'|xargs -i{} docker rm -f {}```
## 参考链接

https://github.com/kubernetes-incubator/service-catalog/blob/master/docs/install.md  
https://github.com/opensds/nbp/blob/master/service-broker/INSTALL.md  
https://kubernetes.io/docs/tasks/inject-data-application/podpreset/  
https://kubernetes.io/docs/concepts/workloads/pods/podpreset/  

## 环境信息:

### OpenSDS:
	url: https://github.com/opensds/opensds   
	commit-id: 504e0ad007f5ab821dd1128a4084dac17408e894
### NBP:
	url: https://github.com/opensds/ndp   
	FlexVolume     commit-id: bfc1eb3e06610fbc610f0cee116957f9f88d9217
	Service-Broker commit-id: 6fa486aadb2198cd5fdb6ff10367bc6d3a068225
### k8s：
	version: v1.9.0-beta.0
	commit-id: a0fb3baa71f1559fd42d1acd9cbdd8a55ab4dfff

	root@ubuntu:~# kubectl version
	Client Version: version.Info{Major:"1", Minor:"9+", GitVersion:"v1.9.0-beta.0-dirty", GitCommit:"a0fb3baa71f1559fd42d1acd9cbdd8a55ab4dfff", GitTreeState:"dirty", BuildDate:"2017-12-13T09:22:09Z", GoVersion:"go1.9.2", Compiler:"gc", Platform:"linux/amd64"}
	Server Version: version.Info{Major:"1", Minor:"9+", GitVersion:"v1.9.0-beta.0-dirty", GitCommit:"a0fb3baa71f1559fd42d1acd9cbdd8a55ab4dfff", GitTreeState:"dirty", BuildDate:"2017-12-13T09:22:09Z", GoVersion:"go1.9.2", Compiler:"gc", Platform:"linux/amd64"}

### ubuntu:
	Ubuntu 16.04.2 LTS \n \l
	Linux ubuntu 4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

### docker:

	root@ubuntu:~/gopath/src/github.com/opensds/nbp/service-broker# docker version 
	Client:
	 Version:      1.12.6
	 API version:  1.24
	 Go version:   go1.6.2
	 Git commit:   78d1802
	 Built:        Tue Jan 31 23:35:14 2017
	 OS/Arch:      linux/amd64
	
	Server:
	 Version:      1.12.6
	 API version:  1.24
	 Go version:   go1.6.2
	 Git commit:   78d1802
	 Built:        Tue Jan 31 23:35:14 2017
	 OS/Arch:      linux/amd64

### WordPress:
```
url: https://github.com/leonwanghui/wordpress
```

代码做了部份修改
```bash
#!/bin/bash

mountedDir="/mnt/wordpress"
path1="/mnt/wordpress/built-in"
path2="/mnt/wordpress/content"
file1="/mnt/wordpress/config.json"

if [ ! -d $path1 ]; then
  cp -r /usr/bin/wordpress/built-in "$mountedDir"
fi

if [ ! -d $path2 ]; then
  cp -r /usr/bin/wordpress/content "$mountedDir"
fi

if [ ! -f $path3 ]; then
  cp /usr/bin/wordpress/config.json "$mountedDir"
  chmod +x /mnt/wordpress/config.json
fi

/usr/bin/wordpress/journey -custom-path="/mnt/wordpress" -log="/mnt/wordpress/log.txt" -http-port=$WORDPRESS_PORT_8084_TCP_PORT
```
