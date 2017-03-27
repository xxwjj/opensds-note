openstack ³õ»¯ÐéÄâ»úÃÜÂë

```
#!/bin/sh
passwd root<<EOF
123456
123456
EOF
passwd ubuntu<<EOF
123456
123456
EOF
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service ssh restart
```