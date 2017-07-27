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

