# 初始状态展示
	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/profiles | python -m json.tool
	
	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/volumes | python -m json.tool
	
	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/snapshots| python -m json.tool
	
	cinder list
	
	cinder snapshot-list
	
	openstack orchestration resource type list|grep OS::OpenSDS::Volume

# heat 编排创建卷

	cat osds-volume.yml
	
	openstack stack create -t osds-volume.yml --parameter "size=1" stack001
	
	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/volumes | python -m json.tool
	
	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/snapshots| python -m json.tool
	
	cinder list
	
	cinder snapshot-list

# 删除编排

	openstack stack delete stack001
	
	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/snapshots| python -m json.tool
	
	cinder snapshot-list
	
	curl -X GET  http://192.168.56.100:50040/api/v1alpha1/block/volumes | python -m json.tool
	cinder list