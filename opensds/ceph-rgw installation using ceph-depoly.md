# ceph-rgw installation using ceph-depoly

## install ceph-depoly
```
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
echo deb https://download.ceph.com/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
sudo apt update
sudo apt install ceph-deploy
```

## ENABLE PASSWORD-LESS SSH
```
ssh-keygen
ssh-copy-id ceph-rgw
``` 
## cephy mon osd depoly

### create working directory
```
mkdir my-cluster
cd my-cluster
```

### starting over
If at any point you run into trouble and you want to start over, execute the following to purge the Ceph packages, and erase all its data and configuration:

```
ceph-deploy purge {ceph-node} [{ceph-node}]
ceph-deploy purgedata {ceph-node} [{ceph-node}]
ceph-deploy forgetkeys
rm ceph.*
```
### depoly
On your admin node from the directory you created for holding your configuration details, perform the following steps using ceph-deploy.
create cluster
```
ceph-deploy new ceph-rgw
```
Add some configuration item for single node.
```
echo "osd crush chooseleaf type = 0" >> ceph.conf
echo "osd pool default size = 1" >> ceph.conf
echo "osd journal size = 100" >> ceph.conf
```
Install Ceph packages
```
ceph-deploy install ceph-rgw
```
Deploy the initial monitor(s) and gather the keys
```
ceph-deploy mon create-initial
```
Use ceph-deploy to copy the configuration file and admin key to your admin node and your Ceph Nodes so that you can use the ceph CLI without having to specify the monitor address and ceph.client.admin.keyring each time you execute a command.
```
ceph-deploy admin ceph-rgw
```

deploy a manager daemon. (Required only for luminous+ builds):
```
ceph-deploy mgr create ceph-rgw
```
Add three OSD
```
ceph-deploy osd create --data /dev/vdb ceph-rgw
```

ADD AN RGW INSTANCE
```
ceph-deploy rgw create ceph-rgw
```

By default, the RGW instance will listen on port 7480. This can be changed by editing ceph.conf on the node running the RGW as follows:
```
[client]
rgw frontends = civetweb port=80
```
create administor
```
radosgw-admin user create --system --uid=admin --display-name=admin --rgw-zone=default --rgw-zonegroup=default --caps=users=*;buckets=*;zone=*;metadata=*;usage=*
```

create normal user
```
radosgw-admin user create --uid="opensds" --display-name="For opensds"  
```

create a bucket in ceph-rgw using python
before execute it set AK/SK
```
export ACCESS_KEY="XT63139MAKEN1DH3ALC6"
export SECRET_KEY="xBQr2hdEkdEg9iaaymkSi2aA7htUMW5fe61hsPGg"
```
add thrid-party library
```
pip install boto
```
``` python
import boto
import boto.s3.connection
import os
access_key = os.environ["ACCESS_KEY"]
secret_key = os.environ["SECRET_KEY"]
conn = boto.connect_s3(
aws_access_key_id = access_key,
aws_secret_access_key = secret_key,
host = '10.10.3.157',
is_secure=False,
calling_format = boto.s3.connection.OrdinaryCallingFormat(),
)
bucket = conn.create_bucket('bucket-opensds')
for bucket in conn.get_all_buckets():
    print "{name}\t{created}".format(
        name = bucket.name,
        created = bucket.creation_date,
)
```

### reference dock
http://docs.ceph.com/docs/master/start/quick-ceph-deploy/

