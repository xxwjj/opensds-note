# ceph plugin 开发记录 #

### ceph Pool 容量
ceph 的动态库里面没有专有接口，来获取ceph Pool的容量。所以只能通过命令行来实现。有两条命令都可以获取到Poll 容量的信息:```ceph df```, ```rados df ```



	root@opensds-master:~# ceph df
	GLOBAL:
	    SIZE       AVAIL     RAW USED     %RAW USED 
	    19053M     6859M       12193M         64.00 
	POOLS:
	    NAME                ID     USED     %USED     MAX AVAIL     OBJECTS 
	    rbd                 0      942M     12.21         2286M         245 
	    test                1         0         0         2286M           1 
	    pool001             2         0         0         2286M           0 
	    testpoolerasure     3         0         0         4573M           0 

GLOBAL里在的AVAIL和POOLS里面的MAX AVAIL有简单的计算关系,如果是REP模式，就是直接除以副本数。如果是EC模式，则POOL的AVAL是Available * k / (m + k)。
其中EC模式计算中的k,m可通过命令行获取到

	root@opensds-master:~# ceph osd erasure-code-profile get default
	k=2
	m=1
	plugin=jerasure
	technique=reed_sol_van


rados df 单位是KB。

	root@opensds-master:~# rados df
	pool name                 KB      objects       clones     degraded      unfound           rd        rd KB           wr        wr KB
	pool001                    0            0            0            0            0            0            0            0            0
	rbd                   965309          245            0          487            0          755         2075          911       967834
	test                       0            1            0            2            0           80           55           33            3
	testpoolerasure            0            0            0            0            0            0            0            0            0
	  total used        12486468          246
	  total avail        7024300
	  total space       19510768


ceph osd crush rule dump

参考文档

http://docs.ceph.com/docs/master/rados/operations/erasure-code/
http://www.cnblogs.com/goldd/p/6610618.html

