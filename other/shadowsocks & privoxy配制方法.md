# shadowsocks 和 privoxy配制方法 #

### 安装 shadowsocks
    pip install shadowsocks
### 运行 sslocal

    sslocal -d start -c /etc/shadowsocks/shadowsocks.json

配制文件如下

	{
	"server":"45.xx.xx.xx",
	"server_port":8388,
	"local_port":1080,
	"password":"sslcoal@123",
	"method":"aes-256-cfb"
	}

### 安装 prirvoxy

    apt-get install python-m2crypto privoxy

### 修改配制文件 `/etc/privoxy/config`
以下两个配制项需修改

	listen-address 0.0.0.0:8118
	forward-socks5 / 127.0.0.1:1080 . 


全部配制如下：

	confdir /etc/privoxy
	logdir /var/log/privoxy
	filterfile default.filter
	logfile logfile
	listen-address  192.168.56.105:8118
	toggle  1
	enable-remote-toggle  0
	enable-remote-http-toggle  0
	enable-edit-actions 0
	enforce-blocks 0
	buffer-limit 4096
	enable-proxy-authentication-forwarding 0
	forward-socks5 / 127.0.0.1:1080 .
	forwarded-connect-retries  0
	accept-intercepted-requests 0
	allow-cgi-request-crunching 0
	split-large-forms 0
	keep-alive-timeout 5
	tolerate-pipelining 1
	socket-timeout 300

### 运行privoxy
	service privoxy restart
