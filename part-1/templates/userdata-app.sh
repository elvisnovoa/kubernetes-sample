#!/bin/bash
sudo su
yum -y update

yum install -y tomcat8-webapps tomcat8-docs-webapp tomcat8-admin-webapps
service tomcat8 start

chkconfig tomcat8 on
