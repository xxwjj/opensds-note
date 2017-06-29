## Server
### 安装
apt install isc-dhcp-server
### 配制
#### vim /etc/default/isc-dhcp-server  
	配置DHCP服务使用哪个网卡接口：
	INTERFACES="eth0"
	
#### vim /etc/dhcp/dhcpd.conf
	ddns-update-style none;
	default-lease-time 600;
	max-lease-time 7200;
	log-facility local7;
	subnet 10.10.0.0 netmask 255.255.255.0 {
	range 10.10.0.150 10.10.0.253;
	option routers 10.10.0.2;
	option subnet-mask 255.255.255.0;
	option broadcast-address 10.10.0.254;
	option domain-name-servers 10.10.0.2;
	option ntp-servers 10.10.0.2;
	option netbios-name-servers 10.10.0.2;
	option netbios-node-type 8;
	}
#### 重启
	service isc-dhcp-server restart

#### 查看dhcp是否正常运行
	sudo netstat -uap


## Client  

#### vi /etc/network/interfaces
	auto eth0
	iface eth0 inet dhcp

#### 用下面的命令使网络设置生效:sudo /etc/init.d/networking restart也可以在命令行下直接输入下面的命令来获取地址sudo dhclient eth0


## 参考文档
http://www.linuxdiyf.com/linux/23299.html
http://os.51cto.com/art/201003/186914.htm