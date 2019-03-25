## Install EulerOS
### For RH2288 v2 
* Reboot the server, press 'Ctr + H' to enter WebBIOS interface.
* Set the boot disk as raid1, and set the others to raid0.
### For RH2285 v2
* Reboot the server,press 'Ctr + C' to enter WebBIOS interface.
* Set the boot disk to raid1, and ingore the other disks.

## Install FM
please reference the product doc.
After you install FM, Modify the fsportal script to make sure you can create a storage pool without ssd cache disk.Here 's the steps:

* Open the script file addStoragePoolCtrl.js
```
vi /opt/omm/oms/workspace0/webapps/fsportal/src/app/business/resource/controllers/storageCluster/storagePool/addStoragePoolCtrl.js
```
* Search keyword 'DiskNoCache', and comment the following code.
```js
//} else if ($scope.hostListTable.data.length <= 0 && /sas_disk|sata_disk/.test(primaryMedia) && cacheMedia === "none"){
 //   errorTip = langInfo.sasDiskSataDiskNoCacheTip;
```

## Install FSA
Brefore you install the FSA please make sure your firewall has been closed. Execute the following command to close:
```
systemctl stop firewalld.service
```
#
