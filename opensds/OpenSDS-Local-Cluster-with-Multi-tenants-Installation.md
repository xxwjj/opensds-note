Here is a tutorial guiding users and new contributors to get familiar with [OpenSDS](https://github.com/opensds/opensds) by installing a simple local cluster and managing lvm device. You can also use the ansible script to install automatically, see detail in [OpenSDS Local Cluster Installation through ansible](https://github.com/opensds/opensds/wiki/OpenSDS-Cluster-Installation-through-Ansible).

## Prepare
Before you start, please make sure you have all stuffs below ready:
- Ubuntu environment (suggest v16.04+).
- More than 30GB remaining disk.
- Make sure have access to the Internet.
- Some tools (`git`, `make` and `gcc`) prepared.

## Step by Step Installation
### Bootstrap
Firstly, you need to download [bootstrap](https://github.com/opensds/opensds/blob/master/script/devsds/bootstrap.sh) script and run it locally with root access.
```shell
curl -sSL https://raw.githubusercontent.com/opensds/opensds/master/script/devsds/bootstrap.sh | sudo bash
```
If there is no error report, you'll have all dependency packages installed.

### Authentication configuration
Because the default authentication strategy is `noauth`, so if you want to enable multi-tenants feature, please set the filed `OPENSDS_AUTH_STRATEGY=keystone` in local.conf file:
```shell
cd $GOPATH/src/github.com/opensds/opensds
vim script/devsds/local.conf
```

### Run all services in one command!
Don't be surprised, you could do it in one command:
```
cd $GOPATH/src/github.com/opensds/opensds && script/devsds/install.sh
```

## Testing
### Config osdsctl tool.
```shell
sudo cp build/out/bin/osdsctl /usr/local/bin
```

### Set some environment variables.
```shell
export OPENSDS_ENDPOINT=http://127.0.0.1:50040
export OPENSDS_AUTH_STRATEGY=noauth # Set the value to keystone for multi-tenants.
```

If you choose keystone for authentication strategy, you need to execute different commands for logging in as different roles:
* For admin role
```shell
source /opt/stack/devstack/openrc admin admin
```
* For user role
```shell
source /opt/stack/devstack/openrc
```

### Create a volume.
```
osdsctl volume create 1 --name=test-001
```

### List all volumes.
```
osdsctl volume list
```

### Delete the volume.
```
osdsctl volume delete <your_volume_id>
```

## Uninstall the local cluster
It's also cool to uninstall the cluster in one command:
```
cd $GOPATH/src/github.com/opensds/opensds && script/devsds/uninstall.sh
```

If you want to destroy the cluster, please run the command below instead:
```
cd $GOPATH/src/github.com/opensds/opensds && script/devsds/uninstall.sh -purge
```

Hope you could enjoy it, and more suggestions are welcomed!