Depoly Kubernetes Dashboard on Local-Cluster
There are two ways to depoly dashboard, you can choose either of them to deploy kube-dashboard.

##  Depoly dashboard using modifed yaml file.
```
wget https://raw.githubusercontent.com/xxwjj/work-note/master/script/kubernetes/kubernetes-dashboard.yaml
kubectl create -f kube-dashboard.yaml
```

## Depoly dashboard manually
### Overwrite the configuration yaml

* vi cluster/addons/dashboard/dashboard-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
  labels:
    k8s-app: kubernetes-dashboard
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  selector:
    k8s-app: kubernetes-dashboard
  ports:
  - port: 443
    targetPort: 8443
    nodePort: 32088
  type: NodePort
```

* vi cluster/addons/dashboard/dashboard-secret.yaml 
```yaml
apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
    # Allows editing resource and makes sure it is created first.
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kubernetes-dashboard-certs
  namespace: kube-system
type: Opaque
data:
  dashboard.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNyakNDQVpZQ0NRRFI0R0tkclk0ZGJqQU5CZ2txaGtpRzl3MEJBUXNGQURBWk1SY3dGUVlEVlFRRERBNXIKZFdKbExXUmhjMmhpYjJGeVpEQWVGdzB4T1RBeU1qY3hNREEyTVRoYUZ3MHlNREF5TWpjeE1EQTJNVGhhTUJreApGekFWQmdOVkJBTU1EbXQxWW1VdFpHRnphR0p2WVhKa01JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBCk1JSUJDZ0tDQVFFQXhHUEI0TUt4TUhsbzB0aDIwS054UmZERnN6YTltY056NFI0K2h3WUsvZkhpN0toR3R6K1QKbU05ZTgyQ1pyL0RYakUwU0t4enFETzM1SlpIZnNHNjdKM3VkQzl4NUF6OCtKck5WM1RPYVRBL1I2bjFmcEtCSAoyenFqaWJJejMraVZtN0M1VEJJejA2S1U2NnJPL1JmVlE2UUR2b0FaN0JzZ2FBRm1uMzlNQ1NIRGtKTVVvMmQ5CmhPek9sdXVpWnBJYXpIUy9PZ3JPUFFxRm1kdWp1aTRNcDFCQmRlSjJGdDZzekRNTmxQY25pbElITzBNUm5hYVQKNU1uL2lrbEtJRW94WVZvK1J0dE1QZVByZC9nNjJJRjZmNUg2T25SVWdlR1RtWmlJU1hvdFBvZ3krbTIvTUVCMgp3MkVVanNnVmZJWS9Ld1FPWVppN1JzYjhvcmpBdkRIOG13SURBUUFCTUEwR0NTcUdTSWIzRFFFQkN3VUFBNElCCkFRQS9KRzVoSU82VXJSdmQwZVVGQ1dLSFh6eDV5UDhLN3F6aFpkZVRtWmNZWVhmL05WVFU0M3UvL2FYOS9hSWYKVnRJZjFldXhwNW1vYklmZ2xlbjNqNU1jWTU1Ky9oaW0zSUJBbmNHS3NJYk1nQ25TWnFUZkNTWTVndktmaHlucApMZTZVTmhML2MveElPQ2Jqd0RNZmJaRDZyeWZxWTk4RGhLcXR1ZXg1WDVleU5qU3cyTWR6SXAydGVGODFzYnBuCnpYZ29LTzZFTTlUL1hMMDBWWFZMUUJieWEzUkRCUlNCNFR6MkdUR3E4TStxeTlNUDdQNjkrY2NJd3ZNU1RrTFQKeEs5M1Rzb2dOb2JoVzlFbm9MaHNtS1pIdFQzbVdsWEtSeWRrdDhVOVBneXJqcm82b1NnTlpSNUg0bHJDYUEzcAo3VytTWVFPem9xREh1aUxEWVQ2QlNoWG8KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
  dashboard.csr: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1hqQ0NBVVlDQVFBd0dURVhNQlVHQTFVRUF3d09hM1ZpWlMxa1lYTm9ZbTloY21Rd2dnRWlNQTBHQ1NxRwpTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFERVk4SGd3ckV3ZVdqUzJIYlFvM0ZGOE1Xek5yMlp3M1BoCkhqNkhCZ3I5OGVMc3FFYTNQNU9ZejE3ellKbXY4TmVNVFJJckhPb003Zmtsa2Qrd2Jyc25lNTBMM0hrRFB6NG0KczFYZE01cE1EOUhxZlYra29FZmJPcU9Kc2pQZjZKV2JzTGxNRWpQVG9wVHJxczc5RjlWRHBBTytnQm5zR3lCbwpBV2FmZjB3SkljT1FreFNqWjMyRTdNNlc2Nkpta2hyTWRMODZDczQ5Q29XWjI2TzZMZ3luVUVGMTRuWVczcXpNCk13MlU5eWVLVWdjN1F4R2RwcFBreWYrS1NVb2dTakZoV2o1RzIwdzk0K3QzK0RyWWdYcC9rZm82ZEZTQjRaT1oKbUloSmVpMCtpREw2YmI4d1FIYkRZUlNPeUJWOGhqOHJCQTVobUx0R3h2eWl1TUM4TWZ5YkFnTUJBQUdnQURBTgpCZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUF1TmF2V0VrR1NNVjZqbEIyZ0EvdWpOdEZ5bVY1a0lMcVZSY2w4MDBEClc5Q3ZTSjA1L2YzT25GeWRia2JyeFBQYlhPOHBmZ0NodnNxZFBsbVRTVE5KbTVVRnNQRlVSMkphS1E0SGNqMHYKR2hUM3Y2V2RyMVhHNVVnVFhvV2E1NDVScno1KzdXZDhQK2dRaDVhOVFqbnpkQkszZHBhOEd3NnJRcGxEbzRmdgpMSkptVzJEM3Vwblg3c29mU2xkTFpiaEI3aFpZaW5jWmVNdW4xeDZJWkxzZ2tGa0lCcjlRU0dYZXZzMjVjTjI0Ckx1ME91VDdTelV1Ky9vbG5BZ0c2SlFuSERWV2duWk1TbGxDTmhZcnhvWllYYWRoZUdTWUVubzRvZCs0Nk5FY3cKam9uUFhTbVZUT2xHZ09XTmdTZnBZRkdrbkJWUVgyNkVJYTVpYUZWa0x0RVNGQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  dashboard.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBeEdQQjRNS3hNSGxvMHRoMjBLTnhSZkRGc3phOW1jTno0UjQraHdZSy9mSGk3S2hHCnR6K1RtTTllODJDWnIvRFhqRTBTS3h6cURPMzVKWkhmc0c2N0ozdWRDOXg1QXo4K0pyTlYzVE9hVEEvUjZuMWYKcEtCSDJ6cWppYkl6MytpVm03QzVUQkl6MDZLVTY2ck8vUmZWUTZRRHZvQVo3QnNnYUFGbW4zOU1DU0hEa0pNVQpvMmQ5aE96T2x1dWlacElhekhTL09nck9QUXFGbWR1anVpNE1wMUJCZGVKMkZ0NnN6RE1ObFBjbmlsSUhPME1SCm5hYVQ1TW4vaWtsS0lFb3hZVm8rUnR0TVBlUHJkL2c2MklGNmY1SDZPblJVZ2VHVG1aaUlTWG90UG9neSttMi8KTUVCMncyRVVqc2dWZklZL0t3UU9ZWmk3UnNiOG9yakF2REg4bXdJREFRQUJBb0lCQUEwakh6VUowUkNORHBZTQpKT2FRQ0dQRlYzUkZsU2xVQ2N4bFdZbHV2ZzErd005VDhtY1B1YS9mTDFyWWUyOXBqUUcxcGlGOExhdnZ2MXJrCkJ6S21OWjdPaGhMbERMTks1NzF2QWE5cVpFZnlSdmlJcW4wNHU1WE90bUhmcWRpd2xsRno0UEZWeG1IQjNuUmwKV0xOVmhNNmhpaDZVTXllNEtOTE1SVEVtTXMvcGRCUUdrZXVXUkw4M09TRWpNaTVxRk9lakQwYVprSDhTTHN1ZwpiR2tXQitkNVdwdEtoOWU1SFQvVzFmMHVXWFh0TlgrbEdYcEd4S3J4SUY4b01XcUNFcG9KbWd3aWJEYytQWlE1CmU0RVQwVG1QTkI4U2lBNGhsMElWd2FjZEpjZG11dW92YlF3NzFpQUpuZDBsL1k5L1pGTDdveWpkM0F6azQydkYKODNuUitnRUNnWUVBL1BoS2dPS2lySkw5V0NpV0pzNjhZOXRsOUtDNGFDUzV1QWR2QjRneklQWHl4cWZUWGVCVQo1ZTZOQTAvY3hEaVhSTjN0ZWJwenJTc3EwRE9tSnhTY0NpWnVJNFMzelZBNU9tN2hYNEFNNU5CRm5kSndVaHEvCjRFazdzYm83Q1hoMW9Ed1pHWGhpc2xXV0liV3dKK2ZzbEFQQzJBbk1ZdGxMbExOYVVNU0JKQ2tDZ1lFQXhyMzMKNFN5cmtnYTV1RWRPdjdRVkRidFdWRS91QTMwUWRlQUVic3NRV2hZeVlVNnhleDR3dWpKdWsyRGhBZWJVUUs0QQpDZWpLVWhJSzUyRlpTeEFsNmNzRzlmeEZrOXBldXlzL0REOUV6UFpIMHluMmcweG9aSjRWbk5DMzJNTjVOakdVCnNTN3dVTkRZSnNZdXFRNDg4dlRON3hLWm14SGRmV0tzOW9WakV5TUNnWUEvQjNwQXZMYzllbTVITGUyamc3VXEKeURxU0JnMk1YVUlzMlNWUDRoNmpJc1Mzdkk4TWY5MkhZTFdmMHFFMS9zZXA4QVhBWTdWNHV4Mnl2SHUwbHd6OQo5bTlReUR1bm0wcDNCYk4vd1A3MWIvTTRqSHRSNmJwUEh0QVJ5MDMwWVNBbHFYT3poZXhKZE11d1lIMmdvOGV0ClpYYUJyNGRPUmNmd0ovUGoxZUk3YVFLQmdINGovTHlTbWFMcFdkODRneWJ4cVpzNW1DV1RSY0k1RXNWK0ZkSXMKV0lpVkpnelU0WmovSkhaSnBCMHVsQ0djM0lMZzdXMWNyMjAvdm1QMVNiTjI0Rmx2WDArcGVvL0pQZThXRjhJeQpOZnpSSSsxRzZRdVU1MzFWU09wckh3VVpyRWxWVnNiT3dBRExUU1h2QzVhSlR1MzFxdTllb3RmbGt1c09RakdGCm44aDVBb0dBYXJOeElYS2RhWFdMbmh2Y2FKcTdzZEtnU0ZQRnQ5QVdwM0phQnFWWmhsMHFPYTN0Vmw3WFpqSk0KS0l6TmFEVHBLL0FtQ2lXQmhWdXN0OUdscCtRNk9veTBLU0NhOHRWUi9iNVRaZ25CSTBoSzNvc0ozUDl3a003Qwo1RlVJZVZiMjA4YTEwRmI4cWpUQVJTNE5JVm5NcGNIRlNUV2dJcllNOWRqYUhpS2x5YlU9Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
    # Allows editing resource and makes sure it is created first.
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kubernetes-dashboard-key-holder
  namespace: kube-system
type: Opaque
```

### Start up the dashboard
```
kubectl create -f cluster/addons/dashboard/
```
### Verify whether the dashboard startup succefully.
```
kubectl -n kube-system get pod
```

##Appendix

### Generate the kubernetes-dashboard-certs manually
```
mkdir -p /etc/kubernetes/addons/certs && cd /etc/kubernetes/addons
openssl genrsa -des3 -passout pass:x -out certs/dashboard.pass.key 2048
openssl rsa -passin pass:x -in certs/dashboard.pass.key -out certs/dashboard.key
openssl req -new -key certs/dashboard.key -out certs/dashboard.csr -subj '/CN=kube-dashboard'
openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
rm certs/dashboard.pass.key
kubectl create secret generic kubernetes-dashboard-certs --from-file=certs -n kube-system
```

### Create admin user
* New a file: vim admin-user.yaml
``` yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
```

* Create admin user
```
kubectl create -f admin-user.yaml
```
* Verify  creating a user
```
kubectl -n kube-system get secret| grep admin 
```
### Get Token

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

### Login dashboard
Input https://xx.xx.xx.xx:32088 go login the kubernetes dashboard.

## Reference:

https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.0/src/deploy/recommended/kubernetes-dashboard.yaml