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

## Notes:

If you server is using "Lsi 2208 raid" raid card, you should install megacli(8.07.10) storcli(1.13.6) tool first.
```
rpm -ivh Lib_Utils-1.00-09.noarch.rpm
rpm -ihv MegaCli-8.02.21-1.noarch.rpm
rpm -ivh storcli-1.16.06-1.noarch.rpm
cd /opt/dsware/agent/script/;sh dsware_smio_tool.sh restart
```

```
sed -i "/p_min_osd_num/s/12/6/" /opt/dsware/manager/webapps/dsware/WEB-INF/SystemConfiguration.xml
sed -i "/g_min_osd_per_server_per_pool/s/2/1/" /opt/dsware/manager/webapps/dsware/WEB-INF/SystemConfiguration.xml
sed -i "/sasDiskSataDiskNoCacheTip/d" `find /opt -name addStoragePoolCtrl.js`
sed -i "/sasDiskSataDiskNoCacheTip/d" `find /opt -name createStoragePoolCtrl.js`
su - omm -c restart_tomcat.noarch.rpm
```
