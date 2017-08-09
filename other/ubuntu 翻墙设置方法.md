ubuntu 翻墙设置方法


## 安装 [shadowsocks-libev](https://teddysun.com/358.html)

### 安装方法

* 使用root用户登录，运行以下命令

		wget --no-check-certificate -O shadowsocks-libev-debian.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-libev-debian.sh
		chmod +x shadowsocks-libev-debian.sh
		./shadowsocks-libev-debian.sh 2>&1 | tee shadowsocks-libev-debian.log

* 安装完成提示如下

		Congratulations, Shadowsocks-libev server install completed!
		Your Server IP        :your_server_ip
		Your Server Port      :your_server_port
		Your Password         :your_password
		Your Encryption Method:your_encryption_method
		
		Welcome to visit:https://teddysun.com/358.html
		Enjoy it!

### 卸载方法
使用 root 用户登录，运行以下命令：

	./shadowsocks-libev-debian.sh uninstall


## 配置全局代理

启动shawdowsocks服务后，发现并不能翻墙上网，这是因为shawdowsocks是socks 5代理，需要客户端配合才能翻墙。

为了让整个系统都走shawdowsocks通道，需要配置全局代理，可以通过polipo实现。

首先是安装polipo：

sudo apt-get install polipo

接着修改polipo的配置文件/etc/polipo/config

	logSyslog = true
	logFile = /var/log/polipo/polipo.log
	
	proxyAddress = "0.0.0.0"
	
	socksParentProxy = "127.0.0.1:1080"
	socksProxyType = socks5
	
	chunkHighMark = 50331648
	objectHighMark = 16384
	
	serverMaxSlots = 64
	serverSlots = 16
	serverSlots1 = 32

重启polipo服务：

	sudo /etc/init.d/polipo restart

为终端配置http代理：

	export http_proxy="http://127.0.0.1:8123/"

接着测试下能否翻墙：

	curl www.google.com

服务器重启后，下面两句需要重新执行：

	sudo sslocal -c shawdowsocks.json -d start
	export http_proxy="http://127.0.0.1:8123/"

参考配制文件shadowsoks config.json

	{
	    "server":"0.0.0.0",
	    "server_port":8388,
	    "local_address": "127.0.0.1",
	    "local_port":1080,
	    "password":"123",
	    "timeout":300,
	    "method":"aes-256-cfb",
	    "fast_open": true,
	    "workers": 5
	}


shadowsocks client.json

	{  
	    "server":"45.76.1.1",  
	    "server_port":8388,  
	    "local_port":1080,  
	    "password":"123",  
	    "method":"aes-256-cfb",
	    "fast_open": true
	}