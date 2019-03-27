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

## Develop a driver for OpenSDS

### Create a new branch for driver.
Since all the new commit will be merged to the development branch firstly, so the new driver branch should be created tracking with the development branch.
```
cd $GOPATH/src/github.com/opensds/opensds
git checkout -b new_driver origin/development
```
### develop code
All drivers should be implement in ```contrib/drivers/```.
* create a driver directory.
``` shell 
mkdir -p contrib/drivers/newdriver
touch contrib/drivers/newdriver/driver.go
``` 
* Develop some driver code like blow:
```golang
//    Licensed under the Apache License, Version 2.0 (the "License"); you may
//    not use this file except in compliance with the License. You may obtain
//    a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
//    License for the specific language governing permissions and limitations
//    under the License.

package newdriver

import (
	"github.com/astaxie/beego/logs"
	. "github.com/opensds/opensds/contrib/drivers/utils/config"
	pb "github.com/opensds/opensds/pkg/dock/proto"
	. "github.com/opensds/opensds/pkg/model"
	"github.com/opensds/opensds/pkg/utils/config"
)

const (
	DefaultConfPath = "/etc/opensds/driver/new_driver.yaml"
	NamePrefix      = "opensds"
)

// These authentication structure an example, you change it depending on you requirements.
type AuthOptions struct {
	Endpoint string `yaml:"endpoint"`
	Name     string `yaml:"name,flow"`
	Password string `yaml:"password,flow"`
}

type Config struct {
	AuthOptions `yaml:"authOptions"`
	Pool        map[string]PoolProperties `yaml:"pool,flow"`
}

type Driver struct {
	conf *Config
}

func (d *Driver) Setup() error {

	conf := &Config{}
	d.conf = conf
	path := config.CONF.OsdsDock.Backends.NewDriver.ConfigPath
	if "" == path {
		path = DefaultConfPath
	}
	Parse(conf, path)
	return nil
}

func (d *Driver) Unset() error {
	return nil
}

func (d *Driver) CreateVolume(opt *pb.CreateVolumeOpts) (*VolumeSpec, error) {
	logs.Info("CreateVolume ...")
	// TODO: create a volume
	return &VolumeSpec{
		BaseModel: &BaseModel{
			Id: opt.GetId(),
		},
		Name:             opt.GetName(),
		Size:             opt.Size,
		Description:      opt.GetDescription(),
		AvailabilityZone: opt.GetAvailabilityZone(),
		PoolId:           opt.GetPoolId(),
		Metadata:         nil,
	}, nil
}

func (d *Driver) PullVolume(volIdentifier string) (*VolumeSpec, error) {
	// Not used , do nothing
	return nil, nil
}

func (d *Driver) DeleteVolume(opt *pb.DeleteVolumeOpts) error {
	logs.Info("DeleteVolume ...")
	// TODO: delete a volume
	return nil
}

func (d *Driver) ExtendVolume(opt *pb.ExtendVolumeOpts) (*VolumeSpec, error) {
	logs.Info("ExtendVolume ...")
	// TODO: extend a volume
	return &VolumeSpec{
		BaseModel: &BaseModel{
			Id: opt.GetId(),
		},
		Name:             opt.GetName(),
		Size:             opt.GetSize(),
		Description:      opt.GetDescription(),
		AvailabilityZone: opt.GetAvailabilityZone(),
	}, nil
}

func (d *Driver) InitializeConnection(opt *pb.CreateAttachmentOpts) (*ConnectionInfo, error) {
	logs.Info("InitializeConnection ...")
	// TODO: initialize a connection
	return &ConnectionInfo{
		DriverVolumeType: ISCSIProtocol,
		ConnectionData:   map[string]interface{}{},
	}, nil
}

func (d *Driver) TerminateConnection(opt *pb.DeleteAttachmentOpts) error {
	logs.Info("InitializeConnection ...")
	//TODO: terminate a connection
	return nil
}

func (d *Driver) CreateSnapshot(opt *pb.CreateVolumeSnapshotOpts) (*VolumeSnapshotSpec, error) {
	logs.Info("CreateSnapshot ...")
	// TODO: create a snapshot
	return &VolumeSnapshotSpec{
		BaseModel: &BaseModel{
			Id: opt.GetId(),
		},
		Name:        opt.GetName(),
		Description: opt.GetDescription(),
		VolumeId:    opt.GetVolumeId(),
		Size:        opt.GetSize(),
	}, nil
}
func (d *Driver) PullSnapshot(snapIdentifier string) (*VolumeSnapshotSpec, error) {
	// Not used, do nothing
	return nil, nil
}

func (d *Driver) DeleteSnapshot(opt *pb.DeleteVolumeSnapshotOpts) error {
	logs.Info("DeleteSnapshot ...")
	// TODO: delete snapshot
	return nil
}

func (d *Driver) ListPools() ([]*StoragePoolSpec, error) {
	logs.Info("ListPools ...")
	var pols []*StoragePoolSpec
	// TODO: Get all pools from actual storage backend, and
	// filter them by items that is configured in  /etc/opensds/driver/newdriver.yaml
	return pols, nil
}

// The interfaces blow are optional, so implement it or it depends on you.
func (d *Driver) InitializeSnapshotConnection(opt *pb.CreateSnapshotAttachmentOpts) (*ConnectionInfo, error) {
	return nil, &NotImplementError{S: "Method InitializeSnapshotConnection has not been implemented yet."}
}

func (d *Driver) TerminateSnapshotConnection(opt *pb.DeleteSnapshotAttachmentOpts) error {
	return &NotImplementError{S: "Method TerminateSnapshotConnection has not been implemented yet."}
}

func (d *Driver) CreateVolumeGroup(
	opt *pb.CreateVolumeGroupOpts,
	vg *VolumeGroupSpec) (*VolumeGroupSpec, error) {
	return nil, &NotImplementError{S: "Method CreateVolumeGroup has not been implemented yet."}
}
func (d *Driver) UpdateVolumeGroup(
	opt *pb.UpdateVolumeGroupOpts,
	vg *VolumeGroupSpec,
	addVolumesRef []*VolumeSpec,
	removeVolumesRef []*VolumeSpec) (*VolumeGroupSpec, []*VolumeSpec, []*VolumeSpec, error) {
	return nil, nil, nil, &NotImplementError{"Method UpdateVolumeGroup has not been implemented yet"}
}
func (d *Driver) DeleteVolumeGroup(
	opt *pb.DeleteVolumeGroupOpts,
	vg *VolumeGroupSpec,
	volumes []*VolumeSpec) (*VolumeGroupSpec, []*VolumeSpec, error) {
	return nil, nil, &NotImplementError{S: "Method DeleteVolumeGroup has not been implemented yet."}
}


```

* Add some code in ```contrib/drivers/driver.go```, so that osdsdock can find your driver.
```golang
// Init
func Init(resourceType string) VolumeDriver {
	var d VolumeDriver
	switch resourceType {
	case config.CinderDriverType:
		d = &cinder.Driver{}
		break
	case config.CephDriverType:
		d = &ceph.Driver{}
		break
	case config.LVMDriverType:
		d = &lvm.Driver{}
		break
	case config.HuaweiDoradoDriverType:
		d = &dorado.Driver{}
		break
	case config.HuaweiFusionStorageDriverType:
		d = &fusionstorage.Driver{}
	// the new dirver is here
	case "new_driver":
		d = &newdriver.Driver{}
	default:
		d = &sample.Driver{}
		break
	}
	d.Setup()
	return d
}

// Clean
func Clean(d VolumeDriver) VolumeDriver {
	// Execute different clean operations according to the VolumeDriver type.
	switch d.(type) {
	case *cinder.Driver:
		break
	case *ceph.Driver:
		break
	case *lvm.Driver:
		break
	case *dorado.Driver:
		break
	case *fusionstorage.Driver:
		break
	// new driver clean up operation
	case *newdriver.Driver:
		break
	default:
		break
	}
	d.Unset()
	d = nil

	return d
}

```

* Add global configuration structure in ```./pkg/utils/config/config_define.go```
```
type Backends struct {
	Ceph                BackendProperties `conf:"ceph"`
	Cinder              BackendProperties `conf:"cinder"`
	Sample              BackendProperties `conf:"sample"`
	LVM                 BackendProperties `conf:"lvm"`
	HuaweiDorado        BackendProperties `conf:"huawei_dorado"`
	HuaweiFusionStorage BackendProperties `conf:"huawei_fusionstorage"`
	// new driver global configuration is here
	NewDriver           BackendProperties `conf:"new_driver"`
}
```

* Build the OpenSDS binary files, the output files are in the ```./build/out/bin```
``` shell
root@ecs-74b4-0001:~/gopath/src/github.com/opensds/opensds# make
mkdir -p /root/gopath/src/github.com/opensds/opensds/build/out
go build -o /root/gopath/src/github.com/opensds/opensds/build/out/bin/osdsdock github.com/opensds/opensds/cmd/osdsdock
go build -o /root/gopath/src/github.com/opensds/opensds/build/out/bin/osdslet github.com/opensds/opensds/cmd/osdslet
go build -o /root/gopath/src/github.com/opensds/opensds/build/out/bin/osdsctl github.com/opensds/opensds/osdsctl
```

* Edit the global configuration file to enbaled the 'new_driver' backend.
```
# new driver section
[new_driver]
name = new_driver
description = New driver Test
driver_name = new_driver
config_path = /etc/opensds/driver/new_driver.yaml

[osdslet]
api_endpoint = 0.0.0.0:50040
graceful = True
log_file = /var/log/opensds/osdslet.log
socket_order = inc
auth_strategy = noauth

[osdsdock]
api_endpoint = 192.168.0.46:50050
log_file = /var/log/opensds/osdsdock.log

enabled_backends = new_driver

[database]
endpoint = 192.168.0.46:62379,192.168.0.46:62380
driver = etcd
```
* Add the driver self-defined yaml files ````vim /etc/opensds/driver/new_driver.yaml``. Here is an example configuration file depends on the structure defined the driver.go .

```yaml
authOptions:
  endpoint: 192.168.0.100
  name: opensds
  password: opensds@123

pool:
  pool001:
    storageType: block
    availabilityZone: nova-01
    extras:
      dataStorage:
        provisioningPolicy: Thin
        isSpaceEfficient: false
      ioConnectivity:
        accessProtocol: DSWARE
        maxIOPS: 7000000
        maxBWS: 600
      advanced:
        diskType: SSD
        latency: 3ms
```

* Then start the OpenSDS services: osdsdock, osdslet. For debugging reason, you can start these services in terminal.
```
killall osdsdock osdslet
./build/out/bin/osdsdock --logtostderr -v 8
./build/out/bin/osdslet --logtostderr -v 8
```

* Check if you driver is you already up.
If you find a new dock named 'new_driver', congratulations your driver is started successfully.
```shell
root@ecs-74b4-0001:~/gopath/src/github.com/opensds/opensds# ./build/out/bin/osdsctl dock list
+--------------------------------------+------------+-----------------+--------------------+------------+
| Id                                   | Name       | Description     | Endpoint           | DriverName |
+--------------------------------------+------------+-----------------+--------------------+------------+
| 7acbb377-9bb1-5688-8e8b-48bfa6e48703 | new_driver | New driver Test | 192.168.0.46:50050 | new_driver |
| 54e901cf-5933-5b3c-9d58-d0da19c6cdd0 | lvm        | LVM Test        | 192.168.0.46:50050 | lvm        |
+--------------------------------------+------------+-----------------+--------------------+------------+
```

Hope you could enjoy it, and more suggestions are welcomed!