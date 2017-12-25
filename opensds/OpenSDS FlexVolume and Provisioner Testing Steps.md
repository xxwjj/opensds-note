# OpenSDS FlexVolume and Provisioner Testing Steps #

## Prerequisite ##
1. kubernetes cluster.
2. opensds cluster.
3. golang environment.

## Operation steps ##
* Download the nbp resource code.
	
	using go get  
	```
	go get -v  github.com/opensds/nbp/...
	```  
	or using git clone  
	```
	git clone https://github.com/opensds/nbp.git  $GOPATH/src/github.com/opensds/nbp
	```

* Build the FlexVolume.

	```
	cd $GOPATH/src/github.com/opensds/nbp/flexvolume
	go build -o opensds ./cmd/flex-plugin/
	```
	
    FlexVolume plugin binary is on the current directory.  


* Copy the OpenSDS FlexVolume to k8s kubelet `volume-plugin-dir`.  
	if you don't specified the volume-plugin-dir, you can execute commands blow:

	```
	mkdir -p /usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds/
	cp $GOPATH/src/github.com/opensds/nbp/flexvolume/opensds /usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds/
	```  
	Note: OpenSDS FlexVolume will get the opensds api endpoint from the environment variable OPENSDS_ENDPOINT, if you don't specified it, the FlexVloume will use the default vaule: `http://127.0.0.1:50040`. if you want to specified the OPENSDS_ENDPOINT executing command `export OPENSDS_ENDPOINT=http://ip:50040` and restart the kubelet.

* Build the Provisioner.

	```
	cd $GOPATH/src/github.com/opensds/nbp/opensds-provisioner/
	make
	```

* Start the Provisioner server.
	```
	cd $GOPATH/src/github.com/opensds/nbp/opensds-provisioner/
	# Tow options need to specified. 
	# using --master to specified the k8s api server endpoint.
	# using --endpoint to specified the opensds api server endpoint.
	./opensds-provisioner --master http://127.0.0.1:8080 --endpoint http://192.168.56.100:50040
	```

* You can use the following cammands to test the OpenSDS Proversion and FlexVolume Functions.

	```
	cd $GOPATH/src/github.com/opensds/nbp/opensds-provisioner/examples
	kubectl create -f sc.yaml              # Create StorageClass
	kubectl create -f pvc.yaml             # Create PVC
	kubectl create -f pod-application.yaml # Create busybox Pod and mount the block storage.
	```
	
	Execute the `findmnt|grep opensds` to confirm whether the volume has been provided.