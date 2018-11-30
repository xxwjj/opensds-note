# keystone installation for multi-cloud
## Keystone installation using devstack
### Add Stack User
Devstack should be run as a non-root user with sudo enabled (standard logins to cloud images such as “ubuntu” or “cloud-user” are usually fine).
* You can quickly create a separate stack user to run DevStack with

```shell
sudo useradd -s /bin/bash -d /opt/stack -m stack
```
* Since this user will be making many changes to your system, it should have sudo privileges:

```shell
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo su - stack
```

### Download DevStack
```shell
git clone https://git.openstack.org/openstack-dev/devstack -b stable/queens
cd devstack
```
The devstack repo contains a script that installs OpenStack and templates for configuration files

### Create a local.conf
Create a local.conf file with 4 passwords opensds@123 at the root of the devstack git repo.
```
[[local|localrc]]
ADMIN_PASSWORD=opensds@123
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
ENABLED_SERVICES=mysql,key
KEYSTONE_BRANCH=stable/queens
KEYSTONECLIENT_BRANCH=stable/queens

```

### Start the install
```
./stack.sh
exit
```
This will take a 15 - 20 minutes, largely depending on the speed of your internet connection. Many git trees and packages will be installed during this process.

### Authentication configuration for multi-cloud.
### Keystone mode 
#### Create account for multi-cloud.
* load openstack command EVNs
``` shell
source /opt/stack/devstack/openrc admin admin
```

* Create user
```shell
openstack user create --domain default --password opensds@123 multicloud
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | default                          |
| enabled             | True                             |
| id                  | 9b4b7d56965d4826a6eb8551a08d48d9 |
| name                | multicloud                       |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+
```

* add rol for user multicloud
```shell
openstack role add --project service --user multicloud admin
```

* create group
```
openstack group create service
```

* add user to group
```
openstack group add user service multicloud
```

* add service group to service role
```
openstack role add service --project service --group service
```

* add admin to group admins
```
openstack group add user admins admin
```

* create multicloudv1 service 
```
openstack service create --name multicloudv1 --description 'Multi-cloud Block Storage' multicloudv1
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Multi-cloud Block Storage        |
| enabled     | True                             |
| id          | 66fe19ce4dce418996f6aea1b6241405 |
| name        | multicloudv1                     |
| type        | multicloudv1                     |
+-------------+----------------------------------+
```

* create endpoint
```
 openstack endpoint create --region RegionOne multicloudv1 public 'http://63.211.111.148:8089/v1/%(tenant_id)s'
+--------------+---------------------------------------------+
| Field        | Value                                       |
+--------------+---------------------------------------------+
| enabled      | True                                        |
| id           | b3470972410242f0afdd3c81376aa302            |
| interface    | public                                      |
| region       | RegionOne                                   |
| region_id    | RegionOne                                   |
| service_id   | 66fe19ce4dce418996f6aea1b6241405            |
| service_name | multicloudv1                                |
| service_type | multicloudv1                                |
| url          | http://63.211.111.148:8089/v1/%(tenant_id)s |
+--------------+---------------------------------------------+
openstack endpoint create --region RegionOne multicloudv1 internal 'http://63.211.111.148:8089/v1/%(tenant_id)s'
+--------------+---------------------------------------------+
| Field        | Value                                       |
+--------------+---------------------------------------------+
| enabled      | True                                        |
| id           | d4fa4b825df34031ba28fa5a032f2ac9            |
| interface    | internal                                    |
| region       | RegionOne                                   |
| region_id    | RegionOne                                   |
| service_id   | 66fe19ce4dce418996f6aea1b6241405            |
| service_name | multicloudv1                                |
| service_type | multicloudv1                                |
| url          | http://63.211.111.148:8089/v1/%(tenant_id)s |
+--------------+---------------------------------------------+
openstack endpoint create --region RegionOne multicloudv1 admin 'http://63.211.111.148:8089/v1/%(tenant_id)s'
+--------------+---------------------------------------------+
| Field        | Value                                       |
+--------------+---------------------------------------------+
| enabled      | True                                        |
| id           | d1cc047b3479419a9f0b5ece28847931            |
| interface    | admin                                       |
| region       | RegionOne                                   |
| region_id    | RegionOne                                   |
| service_id   | 66fe19ce4dce418996f6aea1b6241405            |
| service_name | multicloudv1                                |
| service_type | multicloudv1                                |
| url          | http://63.211.111.148:8089/v1/%(tenant_id)s |
+--------------+---------------------------------------------+
```

# Configuration
Enter the multi-cloud repo directory you downloaded before(eg. ```cd $GOPATH/github.com/opensds/multi-cloud```). Open the configuration file: docker-compose.yml.

* Set the item 'OS_AUTH_AUTHSTRATEGY' to 'keystone'
* set the item 'OS_AUTH_URL' to actual url. you use command ```openstack endpoint list``` to get this information.
* Keep other items in default value.

```yaml
...
  api:
    image: opensdsio/multi-cloud-api
    volumes:
      - /etc/ssl/certs:/etc/ssl/certs
    ports:
      - 8089:8089
    environment:
      MICRO_SERVER_ADDRESS: ":8089"
      MICRO_REGISTRY: "mdns"
      OS_AUTH_AUTHSTRATEGY: "keystone"
      OS_AUTH_URL: "http://10.10.3.100/identity"
      OS_USER_DOMIN_ID: "Default"
      OS_USERNAME: "multicloud"
      OS_PASSWORD: "opensds@123"
      OS_PROJECT_NAME: "service"
...
```

### Noauth mode
Enter the multi-cloud repo directory you downloaded before(eg. ```cd $GOPATH/github.com/opensds/multi-cloud```). Open the configuration file: docker-compose.yml. For noauth mode you should just set the item 'OS_AUTH_AUTHSTRATEGY' to 'noauth': 
```yaml
...
  api:
    image: opensdsio/multi-cloud-api
    volumes:
      - /etc/ssl/certs:/etc/ssl/certs
    ports:
      - 8089:8089
    environment:
      MICRO_SERVER_ADDRESS: ":8089"
      MICRO_REGISTRY: "mdns"
      OS_AUTH_AUTHSTRATEGY: "keystone" # replace keystone with auth
      # If you are using noauth mode, following items do not work, ignore it. 
      OS_AUTH_URL: "http://10.10.3.100/identity"
      OS_USER_DOMIN_ID: "Default"
      OS_USERNAME: "multicloud"
      OS_PASSWORD: "opensds@123"
      OS_PROJECT_NAME: "service"
...
```






