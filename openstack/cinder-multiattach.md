# cinder 设置multiatach

### cinder 命令

```
cinder create --name test001 --allow-multiattach 1
```

### 用curl 执行attach 和dettach操作

#### attach
```
curl -X POST -H "Content-Type: application/json" -H "X-Auth-Token: gAAAAABY2NY9v1Ul_VaN4URxtXo1pn1C5-n2RqOcmM-Rccnuv-q_Z8rc88KlizLwk4B8Hr--giFk9dO0yFfcWmlBI4SWvMbYRLDXHc4oI5Xo2MUnyty1idcGZsPp1vAHhk5o_HpXgUdIER5N7rUeDKWUJnydZy_eVTYG9NQcGnOtaDo4J4CxC2w" -d '{"os-attach": {"host_name": "node-3","mountpoint": "/dev/rbd2"}}' http://controller:8776/v2/363687e299e64c339cb87eebce3083b6/volumes/0a1153ee-06ce-4816-bdd6-aa948429a068/action
```

#### dettach
```
curl -X POST -H "Content-Type: application/json" -H "X-Auth-Token: gAAAAABY2NY9v1Ul_VaN4URxtXo1pn1C5-n2RqOcmM-Rccnuv-q_Z8rc88KlizLwk4B8Hr--giFk9dO0yFfcWmlBI4SWvMbYRLDXHc4oI5Xo2MUnyty1idcGZsPp1vAHhk5o_HpXgUdIER5N7rUeDKWUJnydZy_eVTYG9NQcGnOtaDo4J4CxC2w" -d  '{"os-detach": {"attachment_id": "abd6ea46-253a-4384-8563-44a8f96a147e"}}' http://controller:8776/v2/363687e299e64c339cb87eebce3083b6/volumes/0a1153ee-06ce-4816-bdd6-aa948429a068/action
```
