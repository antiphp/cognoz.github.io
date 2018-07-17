---
layout: post
title: ElasticSearch Kibana Deploy Guide  
tags: elasticsearch java centos linux kibana log
---

### Simple EK Deployment on 1 CentOS 7 node  

Test environment:  
EK version: 6.3 (x-pack included)   
CentOS 7.2 (kernel 3.10)  
2 VCPU, 4GB RAM, 100GB separate blk data storage  
Internet Access  

#### BLK device preparation  
``lsblk  ### find out which device will be used for ES data. Let's assume that its sdb  
fdisk /dev/sdb   ### n,p,enter,enter/dev/sdb1 /opt/es-data                         ext4     defaults        0 0,w  
mkfs.ext4 /dev/sdb1  ### if you have a bigger disk, like 1 TB, xfs would be a better choice    
mkdir /opt/es-data      
vim /etc/fstab``    
*/dev/sdb1 /opt/es-data                         ext4     defaults        0 0*  
``mount -a``    

#### Firewalld   
``firewall-cmd --zone=public --add-port=5601/tcp --permanent  
firewall-cmd --zone=public --add-port=9200/tcp --permanent  
firewall-cmd --zone=public --add-port=9300/tcp --permanent  
firewall-cmd --reload``  

#### Packages  
``rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
vim /etc/yum.repos.d/kibana.repo``  
*[kibana-6.x]  
name=Elastic repository for 6.x packages  
baseurl=https://artifacts.elastic.co/packages/6.x/yum  
gpgcheck=1  
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch  
enabled=1  
autorefresh=1  
type=rpm-md*  
``yum install java-1.8.0-openjdk.x86_64 telnet net-tools kibana elasticsearch``  

#### Dir permissions  
``chown -R elasticsearch:elasticsearch /opt/es-data   
mkdir /var/log/kibana  
touch /var/log/kibana/kibana.log  
chown -R kibana:kibana /var/log/kibana``  

#### ES configuration  
``cat /etc/elasticsearch/elasticsearch.yml``  
*cluster.name: kubernetes  
node.name: node-1  
path.data: /opt/es-data  
action.auto_create_index:   .monitoring-kibana&ast;,.monitoring-data&ast;,.watches,.kibana,.watcher-history&ast;,.monitoring-es&ast;,.security,.triggered_watches  
path.logs: /var/log/elasticsearch  
network.host: 10.220.101.86*  

#### Kibana Configuration  
``cat /etc/kibana/kibana.yml``  
*server.host: 10.220.101.86  
server.name: "kubernetes-kibana"  
elasticsearch.url: "http://10.220.101.86:9200"  
kibana.index: ".kibana"  
logging.dest: /var/log/kibana/kibana.log  
logging.verbose: true  
ops.interval: 2000*  

#### Starting and Enabling Services  
``systemctl enable elasticsearch   
systemctl start elasticsearch  
systemctl enable kibana  
systemctl start kibana``  

#### Create fluentd index  
0. Go to kibana url (like 10.220.101.86:5601 in an example)  
1. Dev-> console  
``PUT fluentd  
{  
    "settings" : {  
        "index" : {  
            "number_of_shards" : 1,   
            "number_of_replicas" : 0  
        }  
    }  
}``  

That's it!  
