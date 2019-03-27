# OpenSDS using FusionStorage Configuration Guide

## Install FusionStorage CLI tool on ubuntu 16.04

FusionStorage CLI hasn't support the ubuntu yet, so you should install CLI tool manually.
Here are installation steps:
* Decompress the RPM package:
```
rpm2cpio fusionstorage-cinder-driver-V6.0-1.0.x86_64.rpm | cpio -div
```

* Copy file manually

```
cd temp/fusionstorage-cinder-driver-V6.0/bin/

mkdir -p /usr/share/dsware
tar xvf jre-8u171-linux-x64.tar.gz -C /usr/share/dsware/

cp lib/ /usr/bin -r
cp conf/ /usr/bin -r
cp fsc_cli /usr/bin
```
* Install python lib.
```
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
apt-get install python-dev -y
pip install psutil
```

* Execute CLI to verify if the CLI tool works well.
```
# Create a volume
fsc_cli --op createVolume --manage_ip 100.163.55.22  --ip 100.163.55.21 --volName app_Vol --poolId 0 --volSize 64 --thinFlag 0
# Show a volume
fsc_cli --op queryVolume --manage_ip 100.163.55.22 --ip 100.163.55.21 --volName app_Vol
```

## Modified the opensds confuration file.

*  Set the fusionStorage as the backend.


vim /etc/opensds/opensds.conf/

```
[osdsdock]
# ...
enabled_backends = huawei_fusionstorage
# ...

[huawei_fusionstorage]
name = fusionstorage backend
description = This is a fusionstorage backend service
driver_name = huawei_fusionstorage
config_path = /etc/opensds/driver/fusionstorage.yaml
```

* FusionStorage driver confiureation file.

vim /etc/opensds/driver/fusionstorage.yaml
```
authOptions:
  username: "admin"
  password: "IaaS@PORTAL-CLOUD9!"
  # Whether to encrypt the password. If enabled, the value of the password must be ciphertext.
  EnableEncrypted: false
  # Encryption and decryption tool. Default value is aes. The decryption tool can only decrypt the corresponding ciphertext.
  PwdEncrypter: "aes"
  url: "https://100.163.55.22:28443"

  fmIp: 100.163.55.22
  fsaIp:
    - 100.163.55.21
    - 100.163.55.22
    - 100.163.55.23

pool:
  0:
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
## Notes
If you want to use the iscsi, you should enabled the iscsi feature and confiure the port number on fusionStorage dashboard.
```
Enter Resource "Pool --> Block Storage Clients --> more --> enable"iSCSI to enable
Enter Resource "Pool --> Block Storage Clients --> more --> Configure iSCSI Port --> Add" to configure iscsi export port. 
```


