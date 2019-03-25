## Install EulerOS
### For RH2288 v2 
* Reboot the server, press Ctr + H enter WebBIOS interface.
* Set the boot disk as raid1, and other set to raid0.
### For RH2285 v2
* Reboot the server, for RH2288 v2 press Ctr + C enter WebBIOS interface.
* Set the boot disk as raid1, and ingore the other disks.

## Install FM
please reference the product doc.
After you install FM, Modified the fsport script to make sure you can create a storage pool without ssd cache disk.Here 's the steps:

*  vi /opt/omm/oms/workspace0/webapps/fsportal/src/app/business/resource/controllers/storageCluster/storagePool/addStoragePoolCtrl.js

* Search keyword DiskNoCache, and commit the following code.
```js
//} else if ($scope.hostListTable.data.length <= 0 && /sas_disk|sata_disk/.test(primaryMedia) && cacheMedia === "none"){
 //   errorTip = langInfo.sasDiskSataDiskNoCacheTip;
```

## Install FSA
Brefore you install the FSA please make sure your firewall has beed closed. Execute the following command to close:
```
systemctl stop firewalld.service
```
#