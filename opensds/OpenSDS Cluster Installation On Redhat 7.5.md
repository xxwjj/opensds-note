## OpenSDS Cluster Installation On Redhat 7.5

### Install OpenSDS dependency library
```
yum install librados2-devel
yum install librbd1-devel
```

### Download binary
```
# etcd
wget https://github.com/etcd-io/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz
cp etcd-v3.3.9-linux-amd64/etcd* /usr/local/bin/

# OpenSDS
wget https://github.com/opensds/opensds/releases/download/v0.3.0/opensds-hotpot-v0.3.0-linux-amd64.tar.gz 
tar xvf opensds-hotpot-v0.3.0-linux-amd64.tar.gz 
cp opensds-hotpot-v0.3.0-linux-amd64/bin/* /usr/local/bin 
```

### Create lvm volume group

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
_create_lvm_volume_group opensds-volumes 10G
```

execute command
```
chmod +x create_vg.sh
./create_vg.sh
```

### Add configuration file.
```
mkdir -p /etc/opensds/driver/
```

vi /etc/opensds/opensds.conf
```
[osdslet]
api_endpoint = 0.0.0.0:50040
graceful = True
log_file = /var/log/opensds/osdslet.log
socket_order = inc
auth_strategy = noauth

[osdsdock]
api_endpoint = 8.46.187.141:50050
log_file = /var/log/opensds/osdsdock.log
# Choose the type of dock resource, only support 'provisioner' and 'attacher'.
dock_type = provisioner
# Specify which backends should be enabled, sample,ceph,cinder,lvm and so on.
enabled_backends = lvm

[database]
endpoint = 8.46.187.141:2479,8.46.187.141:2480
driver = etcd

[lvm]
name = lvm backend 2
description = This is a lvm backend service
driver_name = lvm
config_path = /etc/opensds/driver/lvm.yaml
```

vi /etc/opensds/driver/lvm.yaml
```
[osdslet]
api_endpoint = 0.0.0.0:50040
graceful = True
log_file = /var/log/opensds/osdslet.log
socket_order = inc
auth_strategy = noauth

[osdsdock]
api_endpoint = 8.46.187.141:50050
log_file = /var/log/opensds/osdsdock.log
# Choose the type of dock resource, only support 'provisioner' and 'attacher'.
dock_type = provisioner
# Specify which backends should be enabled, sample,ceph,cinder,lvm and so on.
enabled_backends = lvm

[database]
endpoint = 8.46.187.141:2479,8.46.187.141:2480
driver = etcd

[lvm]
name = lvm backend 2
description = This is a lvm backend service
driver_name = lvm
config_path = /etc/opensds/driver/lvm.yaml
```

### Startup service.
```
mkdir /opt/opensds/etcd/ -p
nohup etcd --advertise-client-urls http://8.46.187.141:2479 --listen-client-urls http://8.46.187.141:2479 --listen-peer-urls http://8.46.187.141:2480 --data-dir /opt/opensds/etcd/data --debug &
osdslet --daemon
osdsdock --daemon
```

### Testing
```
export OPENSDS_ENDPOINT=http://127.0.0.1:50040
export OPENSDS_AUTH_STRATEGY=keystone
osdsctl profile create '{ "name": "default", "description": "default policy", "extra": {} }'
osdsctl volume create 1 -n vol001
```
