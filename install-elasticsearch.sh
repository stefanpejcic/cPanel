#!/bin/bash

clear

echo "running"
rpm --import https://packages.elasticsearch.org/GPG-KEY-elasticsearch
content = "
[elasticsearch-1.4]
name=Elasticsearch repository for 1.4.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1"

echo $content >> /etc/yum.repos.d/elasticsearch.repo

yum -y install elasticsearch

# open port 9200 (for http) and 9300 (for tcp)
sudo iptables -L -n
iptables -A INPUT -p tcp -m tcp --dport 9200 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 9300 -j ACCEPT
service iptables save

chkconfig elasticsearch on

# set min max memory variables
export ES_MIN_MEM=5G
export ES_MAX_MEM=5G

# restart server
service elasticsearch restart
