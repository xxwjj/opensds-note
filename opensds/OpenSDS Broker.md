# OpenSDS Borker
### 删除没有tag的docker images
	docker rmi $(docker images -q -f dangling=true)

### 制作镜像
	cd opensds-broker
	go build .
	docker build . -t leonwanghui/opensds-broker

### 初始化helm
	helm init

### 用helm 安装opensds-broker
	helm install --name opensds-broker charts/opensds-broker
	helm ls --all
	helm delete opensds-broker --purge

查看  

	kubectl get pod
	helm ls

### 解决 问题：./opensds-broker flag redefined: log_dir
	curl https://glide.sh/get | sh
	glid init
	glide install --strip-vendor --strip-vcs

### docker 登录
	docker login --username=leonwanghui --email=wanghui71leon@gmail.com
	docker pull

### 启动local_up_cluster.sh 并使用dns
	KUBE_ENABLE_CLUSTER_DNS=true API_HOST_IP=0.0.0.0 ./hack/local-up-cluster.sh


### 启动 local_up_cluster.sh 设置配制文件路径
	export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig

### 环境变量
	export PATH=$PATH:/usr/local/go/bin:$HOME/gopath/bin:$HOME/kubernetes-1.6.0/cluster
	export GOPATH=$HOME/gopath
	export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig
	export KUBE_ENABLE_CLUSTER_DNS=true
	export API_HOST_IP=0.0.0.0

### 端口扫描
	echo 172.17.0.{1..30} |tr ' ' '\n'| xargs -i{} nc -zv {} 8005