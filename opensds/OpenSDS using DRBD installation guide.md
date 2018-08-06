# OpenSDS using DRBD installation guide
## System requirements
Two nodes are requirements for this deployments scenario: primary node and secondary node.  
For primary node, we need to install all opensds component :osdslet, osdsdock(provisioner, attacher), etcd and drbd.  
For secondary node, we need to install osdsdock (provisioner attacher) and drbd.  

## Deploy in two nodes.
### OpenSDS installation
#### build opensds
```
cd $GOPATH/src/github.com/opensds/opensds/
make
cp build/out/bin/osds* /usr/local/bin
```
#### Startup opensds local_cluster using devsds
```
./script/devsds/install.sh
```
#### Create a volume to Verify local cluster started success.

### DRBD installation

#### installation
```
sudo add-apt-repository ppa:linbit/linbit-drbd9-stack -y
sudo apt-get update
sudo apt-get install drbd-utils python-drbdmanage drbd-dkms
```

#### Add configuration file.
``` yaml
#Minumum and Maximum TCP/IP ports used for DRBD replication
PortMin: 7000
PortMax: 8000
#Exactly two hosts between resources are replicated.
#Never ever change the Node-ID associated with a Host(name)
Hosts:
  - Hostname: primary-node
    IP: 192.168.0.131
    Node-ID: 0
  - Hostname: secondary-node
    IP: 192.168.0.66
    Node-ID: 1
```

## Configuration in primary node.

### restart osdsdock-privisioner
```
killall osdsdock
osdsdock --logtostderr -v 8
```
### osdsdock attacher installation.
#### Add osdsdock-attacher configuration file.

vim /etc/opensds/attacher.conf

```
[osdsdock]
api_endpoint = 192.168.0.131:50051
log_file = /var/log/opensds/osdsdock.log
bind_ip = 192.168.0.131
dock_type = attacher
[database]
endpoint = 192.168.0.131:62379,192.168.0.131:62380
driver = etcd
```
#### Startup osdsdock attacher.
```
osdsdock --config-file /etc/opensds/attacher.conf --logtostderr -v 8
```


## configuration node secondary node.
### stop all services of opensds
```
killall osdslet osdsdock etcd
```

### osdsdock-provisioner configuration.
#### Replace the database endpoint with the endpoint in primary.
vim /etc/opensds/opensds.conf
```
#...
[database]
endpoint = 192.168.0.131:62379,192.168.0.131:62380
driver = etcd
#...
```
#### modified the AZ of lvm backend
vi /etc/opensds/driver/lvm.yaml

```yaml
tgtBindIp: 10.10.3.157
tgtConfDir: /etc/tgt/conf.d
pool:
  opensds-volumes-default:
    diskType: NL-SAS
    availabilityZone: secondary
    extras:
      dataStorage:
        provisioningPolicy: Thin
        isSpaceEfficient: false
      ioConnectivity:
        accessProtocol: iscsi
        maxIOPS: 7000000
        maxBWS: 600
      advanced:
        diskType: SSD
        latency: 5ms
```
#### startup osdsdock-provisioner
```
osdsdock --logtostderr -v 8
```

### osdsdock attacher installation.
#### Add osdsdock-attacher configuration file.
vim /etc/opensds/attacher.conf

```
[osdsdock]
api_endpoint = 192.168.0.66:50051
log_file = /var/log/opensds/osdsdock.log
bind_ip = 192.168.0.66
dock_type = attacher
[database]
endpoint = 192.168.0.131:62379,192.168.0.131:62380
driver = etcd
```
#### Startup osdsdock attacher.
```
osdsdock --config-file /etc/opensds/attacher.conf --logtostderr -v 8
```
