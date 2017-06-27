# 删除没有tag的docker images
	docker rmi $(docker images -q -f dangling=true)

# 制作镜像
	cd opensds-broker
	go build -o opensds-broker
	docker build . -t leonwanghui/opensds-broker

# 初始化helm
	helm init

# 用helm 安装opensds-broker
	helm install --name opensds-broker --namespace opensds-broker charts/opensds-broker
	helm ls --all
	helm delete opensds-broker
	helm delete opensds-broker --purge

查看  

	kubectl get pod -n opensds-broker
	helm ls

# 解决 问题：./opensds-broker flag redefined: log_dir
	curl https://glide.sh/get | sh
	glid init
	glide install --strip-vendor --strip-vcs

# docker 登录
	docker login --username=leonwanghui --email=wanghui71leon@gmail.com
	docker pull