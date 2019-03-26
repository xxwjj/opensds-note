## Reverse proxy ##

### Install apache
```bash
apt-get install apache2
```

### Load proxy relative modules
```bash
a2enmod proxy proxy_balancer proxy_http
service apache2 restart
```

### Set configuration file.

```
cd /etc/apache2/sites-available
touch opensds.conf
ln -s  /etc/apache2/sites-available/opensds.conf /etc/apache2/sites-enabled/opensds.conf
```

Add configuration blow
```
Listen 8000
NameVirtualHost *:8000
<VirtualHost *:8000>
        ServerAdmin webmaster@dummy-host.example.com
        ServerName www.a.com
        ProxyRequests Off
        ProxyMaxForwards 100
        ProxyPreserveHost On
        <Proxy *>
                Order deny,allow
                Allow from all
        </Proxy>
        ProxyPass / http://127.0.0.1:50040/
        ProxyPassReverse / http://127.0.0.1:50040/
</VirtualHost>
```

Other example for virtual host.
```
Listen 8000
NameVirtualHost *:8000
<VirtualHost *:8000> 
    DocumentRoot /opt/opensds
    ServerAdmin webmaster@dummy-host.example.com
    ServerName www.example1.com 
    <Directory "/opt/opensds">
       Options FollowSymLinks
       AllowOverride None
       Require all granted
    </Directory>
</VirtualHost> 
```