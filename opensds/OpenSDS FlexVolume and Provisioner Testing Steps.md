# OpenSDS FlexVolume and Provisioner Testing Steps #

## Prerequisite ##
### ubuntu
* Version infomation

	```
	root@proxy:~# cat /etc/issue
	Ubuntu 16.04.2 LTS \n \l

	```
### docker
* Version information

	```
	root@proxy:~# docker version 
	Client:
	 Version:      1.12.6
	 API version:  1.24
	 Go version:   go1.6.2
	 Git commit:   78d1802
	 Built:        Tue Jan 31 23:35:14 2017
	 OS/Arch:      linux/amd64
	
	Server:
	 Version:      1.12.6
	 API version:  1.24
	 Go version:   go1.6.2
	 Git commit:   78d1802
	 Built:        Tue Jan 31 23:35:14 2017
	 OS/Arch:      linux/amd64
	```

### [golang](https://redirector.gvt1.com/edgedl/go/go1.9.2.linux-amd64.tar.gz) 
* Version infomation

	```
	root@proxy:~# go version
	go version go1.9.2 linux/amd64
	```

* You can install golang by excuting commands blow:

	```
	wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
	tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz
	export PATH=$PATH:/usr/local/go/bin
	export GOPATH=$HOME/gopath
	```

### [kubernetes](https://github.com/kubernetes/kubernetes) local cluster
* Version infomation
	```
	root@proxy:~# kubectl version
	Client Version: version.Info{Major:"1", Minor:"9+", GitVersion:"v1.9.0-beta.0-dirty", GitCommit:"a0fb3baa71f1559fd42d1acd9cbdd8a55ab4dfff", GitTreeState:"dirty", BuildDate:"2017-12-13T09:22:09Z", GoVersion:"go1.9.2", Compiler:"gc", Platform:"linux/amd64"}
	Server Version: version.Info{Major:"1", Minor:"9+", GitVersion:"v1.9.0-beta.0-dirty", GitCommit:"a0fb3baa71f1559fd42d1acd9cbdd8a55ab4dfff", GitTreeState:"dirty", BuildDate:"2017-12-13T09:22:09Z", GoVersion:"go1.9.2", Compiler:"gc", Platform:"linux/amd64"}
	```
* You can startup the k8s local cluster by excuting commands blow:

	```
	git clone https://github.com/kubernetes/kubernetes.git
	cd kubernetes
	git checkout v1.9.0-beta.0
	make
	RUNTIME_CONFIG=settings.k8s.io/v1alpha1=true AUTHORIZATION_MODE=Node,RBAC hack/local-up-cluster.sh -O
	```

### [opensds](https://github.com/opensds/opensds) local cluster
For testing you can deploy OpenSDS referring [Local Cluster Installation with LVM](https://github.com/opensds/opensds/wiki/Local-Cluster-Installation-with-LVM) wiki.

## Testing steps ##
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
	if you don't specify the volume-plugin-dir, you can execute commands blow:

	```
	mkdir -p /usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds/
	cp $GOPATH/src/github.com/opensds/nbp/flexvolume/opensds /usr/libexec/kubernetes/kubelet-plugins/volume/exec/opensds.io~opensds/
	```  
	Note: OpenSDS FlexVolume will get the opensds api endpoint from the environment variable `OPENSDS_ENDPOINT`, if you don't specify it, the FlexVloume will use the default vaule: `http://127.0.0.1:50040`. if you want to specify the `OPENSDS_ENDPOINT` executing command `export OPENSDS_ENDPOINT=http://ip:50040` and restart the k8s local cluster.

* Build the provisioner docker image.

	```
	cd $GOPATH/src/github.com/opensds/nbp/opensds-provisioner/
	make container
	```

* Create service account, role and bind them.
	```
	cd $GOPATH/src/github.com/opensds/nbp/opensds-provisioner/examples
	kubectl create -f serviceaccount.yaml
	kubectl create -f clusterrole.yaml
	kubectl create -f clusterrolebinding.yaml
	```
* Create provisioner pod.
	```
	kubectl create -f pod-provisioner.yaml
	```
* You can use the following cammands to test the OpenSDS FlexVolume and Proversioner functions.

	```
	kubectl create -f sc.yaml              # Create StorageClass
	kubectl create -f pvc.yaml             # Create PVC
	kubectl create -f pod-application.yaml # Create busybox pod and mount the block storage.
	```
	
	Execute the `findmnt|grep opensds` to confirm whether the volume has been provided.

## Clean steps ##

```
kubectl delete -f pod-application.yaml
kubectl delete -f pvc.yaml
kubectl delete -f sc.yaml

kubectl delete -f pod-provisioner.yaml
kubectl delete -f clusterrolebinding.yaml
kubectl delete -f clusterrole.yaml
kubectl delete -f serviceaccount.yaml
```