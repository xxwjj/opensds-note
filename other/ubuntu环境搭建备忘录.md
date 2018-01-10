## 安装virtualbox

### 填加virtualbox源 `sudo vi /etc/apt/source.list`
	
	deb http://download.virtualbox.org/virtualbox/debian xenial contrib

### 安装pulic key并更新库文件
	wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
	wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
	sudo apt-get update
### 安装
	sudo apt-get install virtualbox-5.1
### 参考
https://www.virtualbox.org/wiki/Linux_Downloads

## vnc 安装
### 安装
	sudo apt install xfce4 xfce4-goodies tightvncserver
### 设置密码
	vncserver

### 配制
关闭vnc  

	vncserver -kill :1

备份配制文件

	mv ~/.vnc/xstartup ~/.vnc/xstartup.bak

vim ~/.vnc/xstartup 加入如下配制

	#!/bin/bash
	xrdb $HOME/.Xresources
	startxfce4 &
加权限

	sudo chmod +x ~/.vnc/xstartup
### 为了防止被攻击而无法登录，可以修改监听的端口号 vim /usr/bin/vncserver
	222 #$vncPort = 5900 + $displayNumber;
	223 $vncPort = 1520 + $displayNumber;
	
### 启动

	vncserver

### 下载并安装 vnc viewer
	wget http://tigervnc.bphinz.com/nightly/windows/tigervnc64-1.8.80.exe

### 参考
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-ubuntu-16-04

## 安装ubuntu 虚拟机
- 安装ubuntu的过程中，其中一个步骤需要安装一些基础软件，清注意把OpenserverSSH选上。
- virtaulbox默认没有host-only 网卡，需要手动创建网卡virtualbox 全局设置，ctrl + G 在 Network 里添加一个 adapter，vboxnet0
- 添加完成后用 `ifconfig -a` 查看，如果虚拟网卡没有启动，运行`ifconfig vboxnet0 up` 启动
- 在用ova镜像启动的时候注意网卡的mac地址需要更新一下，不然后会出现ping 包重复的现象。
- 可以在/etc/hostname里面修改hostname.

### 参考
http://blog.csdn.net/yuchao2015/article/details/52132270


## 网络设置
新部署的三台服务器也需要通过本台服务器访问外网，因此需要通过iptables设置nat来访问外网，命令如下
```
sudo iptables -A INPUT -i enp2s0f1 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 10.10.0.0/16  -o enp2s0f0 -j MASQUERADE
```

其它10.10.0.0网段环境访问跳转服务器上的虚拟机，网络配制如下
```
sudo iptables -t nat -A POSTROUTING -s 10.10.0.0/16 -d 192.168.56.0/24 -o vboxnet0 -j MASQUERADE
```
