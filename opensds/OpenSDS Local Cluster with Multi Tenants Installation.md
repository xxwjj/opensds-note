Here is a tutorial guiding users and new contributors to get familiar with [OpenSDS](https://github.com/opensds/opensds) by installing a simple local cluster and managing lvm device. You can also use the ansible script to install automatically, see detail in [OpenSDS Local Cluster Installation through ansible](https://github.com/opensds/opensds/wiki/OpenSDS-Cluster-Installation-through-Ansible).

## Prepare
Before you start, please make sure you have all stuffs below ready:
- Ubuntu environment (suggest v16.04+).
- More than 30GB remaining disk.
- Make sure have access to the Internet.
- Some tools (`git`, `make` and `gcc`) prepared.

## Step by Step Installation
There are three project providing to user: OpenSDS(HotPot), Multi-Cloud, Dashboard.
### OpenSDS(HotPot)
#### Bootstrap
Firstly, you need to download [bootstrap](https://github.com/opensds/opensds/blob/master/script/devsds/bootstrap.sh) script and run it locally with root access.
```shell
curl -sSL https://raw.githubusercontent.com/opensds/opensds/master/script/devsds/bootstrap.sh | sudo bash
```
If there is no error report, you'll have all dependency packages installed.

#### Authentication configuration
Because the default authentication strategy is `noauth`, so if you want to enable multi-tenants feature or want to use Dashboard, please set the field `OPENSDS_AUTH_STRATEGY=keystone` in local.conf file:
```shell
cd $GOPATH/src/github.com/opensds/opensds
vim script/devsds/local.conf
```

#### Run all services in one command!
Don't be surprised, you could do it in one command:
```
cd $GOPATH/src/github.com/opensds/opensds && script/devsds/install.sh
```

### Multi-Cloud (Gelato)
Run command blow to bootstrap multi-cloud.
```shell
curl -sSL https://raw.githubusercontent.com/opensds/multi-cloud/master/script/bootstrap.sh | sudo bash
```
It will take a 10~15 minutes depending on the speed of your internet connection. After this docker and docker-compose which is needed by multi-cloud will be installed, and multi-cloud service will be started up too. If  OPENSDS_AUTH_STRATEGY was set as  'keystone', the script will create user,service, endpoint in keystone for multi-cloud automatically.

### Dashboard

```
docker run -d --net=host --name opensds-dashborad opensdsio/dashboard:latest
```

## Testing
### Testing local cluster using dashboard.
Open your browser and input dashboard URL: http://hostIP:8088 to enter OpenSDS dashboard. Following is the initial account for administrator user:
```
UserName: admin
Password: opensds@123
```
### Testing OpenSDS(Hotpot) using CLI.
We have provided CLI for OpenSDS(HotPot), if you simply want to testing OpenSDS(Hotpot), and do not want to deploy dashboard, CLI is a good choice.
#### Config osdsctl tool.
```shell
sudo cp $GOPATH/src/github.com/opensds/opensds/build/out/bin/osdsctl /usr/local/bin
```

#### Set some environment variables.
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

#### Create a volume.
```
osdsctl volume create 1 --name=test-001
```

#### List all volumes.
```
osdsctl volume list
```

#### Delete the volume.
```
osdsctl volume delete <your_volume_id>
```

## Uninstall the local cluster
### OpenSDS(HotPot)
It's also cool to uninstall the cluster in one command:
```
cd $GOPATH/src/github.com/opensds/opensds && script/devsds/uninstall.sh
```

If you want to destroy the cluster, please run the command below instead:
```
cd $GOPATH/src/github.com/opensds/opensds && script/devsds/uninstall.sh -purge
```
### Multi-Cloud
```
cd $GOPATH/src/github.com/opensds/multi-cloud
docker-compose down
```
### Dashboard
```
docker stop opensds-dashborad
docker rm opensds-dashborad
```
Hope you could enjoy it, and more suggestions are welcomed!
