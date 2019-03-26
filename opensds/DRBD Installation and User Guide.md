# DRBD Installation and User Guide
## installation

```
add-apt-repository ppa:linbit/linbit-drbd9-stack
apt-get update
apt-get install drbd-utils python-drbdmanage drbd-dkms
```
## drbdadm user guide

### check drbdadm status
```
drbdadm status
```
### create replication pair
* add a configruation file like blow:
vim /etc/drbd.d/resourcename.res
```
# meta-data-json:{"updated": "2019-02-25 06:19:49.348155621 +0000 UTC"}
resource b0e5590c-9a75-4164-b76c-d156ddaede71 {
   on ecs-f386-0002 {
      node-id 1;
      address 192.168.0.39:7000;
      volume 0 {
         device minor 1;
         disk /dev/sdb;
         meta-disk internal;
      }
   }

   on ecs-606e {
      node-id 0;
      address 192.168.0.11:7000;
      volume 0 {
         device minor 1;
         disk /dev/sda;
         meta-disk internal;
      }
   }

   on ecs-890e {
      node-id 2;
      address 192.168.0.64:7000;
      volume 0 {
         device minor 2;
         disk /dev/dm-0;
         meta-disk internal;
      }
   }

   connection-mesh {
      hosts ecs-890e ecs-f386-0002 ecs-606e;
      #hosts ecs-890e ecs-606e;
   }
}
```
* copy configruation file to other nodes which is configured in file.
```
scp /etc/drbd.d/resourcename.res root@ecs-f386-0002:/etc/drbd.d/
scp /etc/drbd.d/resourcename.res root@ecs-890e:/etc/drbd.d/
```

* create md data on all cluster nodes.
```
drbdadm create-md resourcename
```

* startup replication on each node.

```
drbdadm up resourcename
```

* sync up data 
```
drbdadm primary resourcename --force
```

* After sync up, change back the replication rol
```
drbdadm secondary resourcename
```
## drbdmanage user guide

drbdmanage is based on lvm, so you should install lvm firstly.

* create a lvm volume group for drbd, tne name should be 'drbdpool' by default.
```
truncate -s 20G /opt/drbd.img
losetup -f --show /opt/drbd.img
pvcreate /dev/loop0
vgcreate drbdpool /dev/loop0
```
* initialize cluster
```
drbdmanage init 192.168.56.11
```
* We now need to add in additional nodes to the cluster. We run the commands on the host that has SSH Public Key Authentication access to the other nodes.
```
ssh-keygen
ssh-copy-id other_nodes
```
* add nodes
```
# drbdmanage add-node <name> <ip>
drbdmanage add-node node2 192.168.56.12
```
* show nodes to verify the if add success.
```
drbdmanage list-nodes
```
* add volume
```
drbdmanage add-resource web
drbdmanage add-volume web 200MB
drbdmanage deploy-resource web 3
drbdmanage add-volume web 200MB --deploy 3
```
## References
* https://docs.linbit.com/docs/users-guide-9.0/
* https://www.theurbanpenguin.com/create-3-node-drbd-9-cluster-using-drbd-manage/

