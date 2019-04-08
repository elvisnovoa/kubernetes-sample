#!/bin/bash
sudo su - root
yum -y update

yum -y install httpd
echo "ProxyPass /app http://${app_lb}:8080/
ProxyPassReverse /app http://${app_lb}:8080/" >> /etc/httpd/conf/httpd.conf

service httpd start
chkconfig httpd on

echo "UP" > /var/www/html/index.html
