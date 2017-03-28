### Build a Private Docker Registry

### Ubuntu 安装docker

```
wget -qO- https://get.docker.com/ | sh
```

### 修改配制

新版本的docker默认支持https,而registry只支持http,因此需要修改docker配制
在 /etc/default/docker 中添加如下信息
```
DOCKER_OPTS="$DOCKER_OPTS --insecure-registry=10.27.19.230:5000"
```

重启docker
```
service docker restart
```

### 搭建仓库

下载仓库镜像
```
docker pull registry
```

启动
```
docker run -d -p 5000:5000 -v /opt/data/registry:/tmp/registry registry
```

查询  

如果我们想要查询私有仓库中的所有镜像，使用docker search命令：
```
docker search registry_ip:5000/
```

如果要查询仓库中指定账户下的镜像，则使用如下命令：
```
docker search registry_ip:5000/account/
```

查询镜像状态

``` bash
curl -XGET http://registry:5000/v2/_catalog

curl -XGET http://registry:5000/v2/image_name/tags/list
```

### 镜像制作

下载镜像

```
docker pull ubuntu:14.04
```

启动镜像
```
docker run -d -it ubuntu:14.04 /bin/bash
```

进入镜像并编辑镜像

```
docker exec -it 8bbb8a7d869b2d28dce88d8c68e8d46e05233dab85308072aee81b90685d102f /bin/bash
```

commit镜像

```
docker commit ce557e9da828 10.31.173.180:opensds
```


### 上传镜像

```
docker push 10.31.173.180:opensds
```

### 下载和运行镜像

```bash
docker pull 10.31.173.180:opensds

docker run -d -it  -p50050:50050 10.31.173.180:5000/opensds /usr/local/bin/osdsdock
```

### Reference:

http://blog.csdn.net/wangtaoking1/article/details/44180901/
https://github.com/widuu/chinese_docker/blob/master/installation/ubuntu.md