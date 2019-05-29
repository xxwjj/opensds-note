# OpenSDS Telemetry Installation Guide

OpenSDS Telemetry provides metrics feature for Users. All features is based on prometheus, and kafka.

## kafka installation
kafka need zookeeper and JDK, so you must install them first.

### JDK Installation

* visist http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html  to download the JDK.

* uppack the JDK:
```
tar xvf jdk-12.0.1_linux-x64_bin.tar.gz -C /usr/local
```

* Set the JDK ENV:
Add following content into file: /etc/profile
```
export JAVA_HOME=/usr/local/jdk-12.0.1
export JRE_HOME=$JAVE_HOME/jre
export CLASSPATH=$CLASSPATH:.:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin
```

* Check if JDK is installed succeffully.
```
root@opensds:~/kafka# source /etc/profile
root@opensds:~/kafka# java --version
java 12.0.1 2019-04-16
Java(TM) SE Runtime Environment (build 12.0.1+12)
Java HotSpot(TM) 64-Bit Server VM (build 12.0.1+12, mixed mode, sharing)

```

### Zookeeper Installation
If you don't want install zookeeper, you can skip following steps, and use the convenience script packaged with kafka to get a quick-and-dirty single-node ZooKeeper instance.

* download zookeeper
```
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.3.6/zookeeper-3.3.6.tar.gz 
tar -zxvf zookeeper-3.3.6.tar.gz -C /usr/local/
```

* Add the following to file:/etc/profile
```
export zookeeper_home=/usr/local/kafka/zookeeper-3.3.6
```

* start the zookeeper.
```
source /etc/profile
./zkServer.sh start
```
### Kafka Installation.
Please refer to web: https://kafka.apache.org/quickstart

## prometheus:
Please refer to: https://www.digitalocean.com/community/tutorials/how-to-install-prometheus-on-ubuntu-16-04
