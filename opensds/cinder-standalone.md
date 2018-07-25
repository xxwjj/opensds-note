# **cinder-standalone** #

## install docker (install the newest version maybe better.)
	wget -qO- https://get.docker.com/ | sh
	
## install docker-compose
	apt-get install docker-compose

## install golang
	wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
	tar xvf go1.10.3.linux-amd64.tar.gz -C /usr/local/
	export GOPATH=$HOME/gopath
	export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

## install make
	apt-get install make

## download the opensds source code and build it.
	mkdir $GOPATH/src/github.com/opensds
	cd $GOPATH/src/github.com/opensds
	git clone https://github.com/opensds/opensds.git
	make

## install cinder standalone
### download cinder source code

	mkdir ~/cinder-standalone
	cd ~/cinder-standalone
	git clone https://github.com/openstack/cinder.git
### Modified the Makefile (vim ~/cinder-standalone/contrib/block-box)
The testing ENV is ubuntu:xenial, so you should repalce the PLATFORM variable 
from
```	
PLATFORM ?= debian:stretch# ubuntu:xenial, centos:7
```
to
```
PLATFORM ?= ubuntu:xenial
```

### build docker images

	cd cinder/contrib/block-box
	make blockbox
	
I have pushed created images in dockerhub, you can pull it instead of building.

	docker pull xxwjj/debian-cinder
	docker pull xxwjj/lvm-debian-cinder
	docker tag xxwjj/debian-cinder:latest debian-cinder:latest
	docker tag xxwjj/lvm-debian-cinder lvm-debian-cinder:latest

### create cinder lvm backend volume group


vi  create_vg.sh 
```bash
#!/bin/bash
function _create_lvm_volume_group {
    local vg=$1
    local size=$2

    local backing_file=/opt/opensds/cinder/cinder-volume.img
	mkdir /opt/opensds/cinder/ -p
    if ! sudo vgs $vg &> /dev/null ; then
        # Only create if the file doesn't already exists
        [[ -f $backing_file ]] || truncate -s $size $backing_file
        local vg_dev
        vg_dev=`sudo losetup -f --show $backing_file`

        # Only create physical volume if it doesn't already exist
        if ! sudo pvs $vg_dev; then
            sudo pvcreate $vg_dev
        fi

        # Only create volume group if it doesn't already exist
        if ! sudo vgs $vg; then
            sudo vgcreate $vg $vg_dev
        fi
    fi
}
modprobe dm_thin_pool
_create_lvm_volume_group cinder-volumes 10G
```
execute command

	chmod +x create_vg.sh
	./create_vg.sh


### startup cinder-standalone
	cd cinder-standlone/cinder/contrib/block-box/
	docker-compose up 

### install cinder CLI
	wget https://bootstrap.pypa.io/get-pip.py
	python get-get.py
	pip install python-cinderclient


## Set the cinder-standalone as the opensds backend.
### vim /etc/opensds/opensds.conf
	[osdsdock]
	...
	enabled_backends = cinder
	...
	[cinder]
	name = cinder
	description = Cinder Test
	driver_name = cinder
	config_path = /etc/opensds/driver/cinder.yaml
### vim /etc/opensds/driver/cinder.yaml

```yaml
authOptions:
  noAuth: true
  endpoint: "http://127.0.0.1/identity"
  cinderEndpoint: "http://127.0.0.1:8776/v2"
  domainId: "Default"
  domainName: "Default"
  username: ""
  password: ""
  tenantId: "myproject"
  tenantName: "myproject"
pool:
  # The pool name must be same as the pool name in cinder, you can run command
  # 'cinder get-pools' to get.
  "cinder-lvm@lvm#lvm":
    storageType: block
    availabilityZone: default
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
        latency: 3ms
```

### set osdsctl ENV variable.
    export OPENSDS_AUTH_STRATEGY=noauth
    export OPENSDS_ENDPOINT=http://127.0.0.1:50040



