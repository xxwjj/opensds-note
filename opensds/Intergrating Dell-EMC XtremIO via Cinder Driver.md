# Intergrating Dell-EMC XtremIO via Cinder Driver
OpenSDS doesn't have XtremIO Driver currentlly, but we integrate it via cinder driver, here are guide how to integrate XtremIO.

## edit cinder.conf and add the configuration below.

* To retrieve the management IP, use the show-xms CLI command.
Configure the management IP by adding the following parameter:
```
san_ip = XMS Management IP
```
* To retrieve the cluster name, run the show-clusters CLI command.
Configure the cluster name by adding the following parameter:
```
xtremio_cluster_name = Cluster-Name
```

* Create an XMS account using either the XMS GUI or the add-user-account CLI command.
Configure the user credentials by adding the following parameters:
```
san_login = XMS username
san_password = XMS username password
```
* Configuration example:

```bash
[DEFAULT]
# ...
enabled_backends = xtremio
xtremio_array_busy_retry_count = 5
xtremio_array_busy_retry_interval = 5
xtremio_cluster_name = hwxio
xtremio_volumes_per_glance_cache = 100
# ...
[xtremio]
volume_driver = cinder.volume.drivers.dell_emc.xtremio.XtremIOISCSIDriver
volume_backend_name = xtremio
xtremio_cluster_name = hwxio
san_ip = 8.44.101.140
san_login = opensds
san_password = opensds123
#driver_ssl_cert_verify = true
#driver_ssl_cert_path = /etc/cinder/xms_root_ca.cer
```
## OpenSDS cinder configureation:
### edit opensds.conf
vim /etc/opensds/opensds.conf

```bash
[osdsdock]
...
enabled_backends = cinder
...
[cinder]
name = cinder
description = Cinder Test
driver_name = cinder
config_path = /etc/opensds/driver/cinder.yaml
```

### edit cinder.yaml
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

## reference:

https://docs.openstack.org/mitaka/config-reference/block-storage/drivers/emc-xtremio-driver.html
