À©ÈİÃüÁî£º
```
kubectl get -o json rc opensds-rc-ceph | sed 's,"replicas": 1,"replicas": 2,g' | kubectl replace -f -
```