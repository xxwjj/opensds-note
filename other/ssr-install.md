# shadowsock install

### 安装 BBR
可参考文档：https://teddysun.com/489.html

使用root用户登录，运行以下命令：
```
wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
chmod +x bbr.sh
./bbr.sh
```
安装完成后，脚本会提示需要重启 VPS，输入 y 并回车后重启。
重启完成后，进入 VPS，验证一下是否成功安装最新内核并开启 TCP BBR，输入以下命令：
```
uname -r
```
查看内核版本，含有 4.10 就表示 OK 了
```
sysctl net.ipv4.tcp_available_congestion_control
```
返回值一般为：
```
net.ipv4.tcp_available_congestion_control = bbr cubic reno
```
```
sysctl net.ipv4.tcp_congestion_control
```
返回值一般为：
```
net.ipv4.tcp_congestion_control = bbr
```
```
sysctl net.core.default_qdisc
```
返回值一般为：
```
net.core.default_qdisc = fq
```
```
lsmod | grep bbr
```
返回值有 tcp_bbr 模块即说明bbr已启动

### shadownsock安装方法
```
wget https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
bash shadowsocks-all.sh 
```
参考：

https://teddysun.com/486.html


https://www.nnbbxx.net/post-7022.html

