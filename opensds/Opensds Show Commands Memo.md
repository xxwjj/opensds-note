# OpenSDS Command Note

## 1.Basic Scenario 

## 1.1 Create Storage Resource 

### 1.1.1 Create a LVM volume with cinder(Note:backend is cinder)
#### Query  
```
osdsctl volume list -b cinder
```   

#### Create  
```
osdsctl volume create 1 --name lvm001 --type lvm -b cinder

cinder list #Query after create use cinder command.
```  
#### Delete  
```
osdsctl volume delete 35ebf968-fa8c-4656-a045-d9b730355701 -b cinder
cinder list #Query afater delete use cinder command.
```  
#### Also can query volume info by command **```cinder list```**

```
root@cnlvr01r04c31:~# cinder list
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
|                  ID                  |     Status     |     Name     | Size | Volume Type | Bootable | Attached to |
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
| 35ebf968-fa8c-4656-a045-d9b730355701 |   available    |    lvm001    |  1   |     lvm     |  false   |             |
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
```


### 1.1.1 Create a CEPH volume with cinder (Note: backend is cinder)
####Create  

```
osdsctl volume create 1 --name ceph001 --type ceph -b cinder
cinder list # Query after list use cinder command.
```

#### Delete  
```
osdsctl volume delete 1aff3eb0-1860-4ece-9c12-20b3d93913a5 -b cinder
cinder list #Query afater delete use cinder command.
```

### 1.1.2 Create a volume with coprhd(Note:backen is coprhd)

#### Query
```
osdsctl volume list -b coprhd
```

#### Create
```
osdsctl volume create 1 --name coprhd -b coprhd
osdsctl volume list -b coprhd #Query after create.
```

#### Delete
```
osdsctl volume delete urn:storageos:Volume:ed39ad67-d316-4a9c-ba10-f7797f3e2d71:vdc1 -b coprhd
osdsctl volume list -b coprhd # Query after delete.
```
### 1.1.3 Create a NFS share with manila
#### Query  
```
osdsctl share list -b
```  
#### Create  
```
osdsctl share create nfs 1 -n nfsshare001
manila list # Query after create nfs shsare use manila command.
```  
#### Delete   
```
osdsctl share delete  67034c60-55ff-4774-b225-9ed0c73400de
manila list # Query after create nfs shsare use manila command.
```  
#### You can also query the share via command ```manila list```  
```
root@cnlvr01r04c31:~# manila list
+--------------------------------------+-------------+------+-------------+-----------+-----------+--------------------+----------------------------------+-------------------+
| ID                                   | Name        | Size | Share Proto | Status    | Is Public | Share Type Name    | Host                             | Availability Zone |
+--------------------------------------+-------------+------+-------------+-----------+-----------+--------------------+----------------------------------+-------------------+
| 67034c60-55ff-4774-b225-9ed0c73400de | nfsshare001 | 1    | NFS         | available | False     | default_share_type | cnlvr02r08s4@lvm#lvm-single-pool | nova              |
+--------------------------------------+-------------+------+-------------+-----------+-----------+--------------------+----------------------------------+-------------------+
```
## 1.2 Provide a volume to k8s

#### Set label to node
```
kubectl label nodes 10.2.1.233 disktype=ceph233 --overwrite
```

#### Startup the nginx server and provider a volume to it.
```
root@cnlvr01r04c31:~/demo_yaml# kubectl create -f opensds_lvm.yaml 
pod "nginx-lvm" created
```
#### The volume status is "in-use"
```
root@cnlvr01r04c31:~/demo_yaml# cinder list
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
|                  ID                  |     Status     |     Name     | Size | Volume Type | Bootable | Attached to |
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
| 780c3771-10c7-42a9-b69b-9c2ea400d1b3 |     in-use     |   lvm_test   |  1   |     lvm     |  false   |     None    |
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
```

#### Enter into container and view the volume infomation.
```
root@cnlvr01r04c31:~/demo_yaml# kubectl exec -it nginx-lvm sh
# df -hl
Filesystem                                                                    Size  Used Avail Use% Mounted on
none                                                                          241G  7.2G  222G   4% /
tmpfs                                                                          63G     0   63G   0% /dev
tmpfs                                                                          63G     0   63G   0% /sys/fs/cgroup
/dev/mapper/cinder--volumes-volume--780c3771--10c7--42a9--b69b--9c2ea400d1b3  976M  1.3M  908M   1% /data
/dev/dm-0                                                                     241G  7.2G  222G   4% /etc/hosts
shm                                                                            64M     0   64M   0% /dev/shm
tmpfs                                                                          63G     0   63G   0% /sys/firmware
# ls /data/ -l
total 16
drwx------ 2 root root 16384 Mar 14 09:40 lost+found
```

#### Query pod status kubectl get pod -o wide
```
root@cnlvr01r04c31:~/demo_yaml# kubectl get pod -o wide
NAME                  READY     STATUS              RESTARTS   AGE       IP            NODE
kube-dns-v9-5fjb8     3/3       Running             0          8d        172.17.35.2   10.2.1.234
nginx-lvm             1/1       Running             0          3m        172.17.34.4   10.2.1.233
```

#### Delete pod
```
root@cnlvr01r04c31:~/demo_yaml# kubectl delete pod nginx-lvm
pod "nginx-lvm" deleted
```

#### The Volume status is back to available.
```
root@cnlvr01r04c31:~/demo_yaml# cinder list
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
|                  ID                  |     Status     |     Name     | Size | Volume Type | Bootable | Attached to |
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
| 780c3771-10c7-42a9-b69b-9c2ea400d1b3 |   available    |   lvm_test   |  1   |     lvm     |  false   |             |
+--------------------------------------+----------------+--------------+------+-------------+----------+-------------+
```

#### The yaml file
```ymal
apiVersion: v1
kind: Pod
metadata:
  name: nginx-lvm
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: test
      mountPath: /data
    ports:
    - containerPort: 80
  nodeSelector:
    disktype: ceph233
  volumes:
  - name: test
    flexVolume:
      driver: "opensds.io/opensds"
      fsType: "ext4"
      options:
        volumeID: "780c3771-10c7-42a9-b69b-9c2ea400d1b3"
        resourceType: "cinder"
        volumeType: "lvm"
```

## 2 Scale Out Scenario

#### Show node status
```
root@cnlvr01r04c31:~# kubectl get nodes
NAME         STATUS     AGE
10.2.1.234   NotReady   9d
10.2.1.233   Ready      9d
```

#### Create ngnix server and mount volume at node 233.
```
root@cnlvr01r04c31:~/demo_yaml# kubectl create -f  opensds_ceph233.yaml 
pod "nginx-ceph233" created
```

#### Start the 234 node
```
nohup kubelet --volume-plugin-dir=/root/plugins/ --cluster_dns=10.254.0.3 --cluster_domain=cluster.local --logtostderr=false --v=0 --allow-privileged=false  --log_dir=/usr/local/kubernete_test/logs/kube --address=0.0.0.0 --port=10250 --hostname_override=10.2.1.234 --api_servers=http://10.2.0.115:8080 >> /usr/local/kubernete_test/logs/kube-kubelet.log 2>&1 &
```

#### Query node status
```
root@cnlvr01r04c31:~# kubectl get nodes
NAME         STATUS     AGE
10.2.1.234   Ready      9d
10.2.1.233   Ready      9d
```

#### Create ngnix server and mount volume at node 234
```
root@cnlvr01r04c31:~/demo_yaml# kubectl create -f  opensds_ceph234.yaml 
pod "nginx-ceph234" created
```

#### Query pod status
```
root@cnlvr01r04c31:~/demo_yaml# kubectl get pod
NAME                READY     STATUS    RESTARTS   AGE
kube-dns-v9-5fjb8   3/3       Running   0          8d
nginx-ceph233       1/1       Running   0          5m
nginx-ceph234       1/1       Running   0          29s
```
