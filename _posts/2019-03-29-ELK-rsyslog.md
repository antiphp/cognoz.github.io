---
layout: post  
title: Connecting rsyslog with ELK  
tags: ELK elasticsearch kibana logstash rsyslog log
---


### Intro  
Mission: Install ELK on VM , configure rsyslog export to Logstash -> ElasticSearch

### Prerequisites  
1 VM with installed centos 7 (4/8 ram, 2/4cpu,+100GB )
+
1 target VM with configured default rsyslog


### Deployment  
Configure basic stuff on target VM for ansible -  
- ssh-keys  
- python-minimal  

``ssh deployvm  
cd /opt
git clone https://github.com/sadsfae/ansible-elk.git
cd ansible-elk
git checkout 5.6
vim hosts #place your target vm ip there
#I do NOT use elk-client, but its up to you``   

Configure vars    
vim [install/group_vars/all.yml]({{"/listings/2019-03-29-ELK-rsyslog/all.yml"}})

Play  
``ansible-playbook -i hosts install/elk.yml``  

If all goes well, then you should access your kibana dashboard on http//$target_IP:80  

raybeRsyslog.conf or iptables(for example, I dont have firewalld on my CentOS7.6 machines).  
On target machine:  
``iptables -I INPUT 1 -p tcp --dport 9600 -j "ACCEPT"
iptables -I INPUT 1 -p tcp --dport 9200 -j "ACCEPT"
iptables -I INPUT 1 -p tcp --dport 80 -j "ACCEPT"
iptables -I INPUT 1 -p udp --dport 514 -j "ACCEPT"``  

### Configure json templating and exporting on machine with rsyslog  
vim /etc/rsyslog.conf
[rsyslog.conf]({{"/listings/2019-03-29-ELK-rsyslog/rsyslog.conf}})  

vim /etc/rsyslog.d/22-test.conf
[22-messages.conf]({{"/listings/2019-03-29-ELK-rsyslog/22-messages.conf}})

Install rsyslog-mmjsonparse:  
``yum install -y rsyslog-mmjsonparse``  

### Configure Logstash on ELK node  
vim /etc/logstash/conf.d/logstash.conf
[logstash.conf]({{"/listings/2019-03-29-ELK-rsyslog/logstash.conf}})

### Restart rsyslog / Logstash  
ELK  
``ssh elk
systemctl restart logstash
tail -f /var/log/logstash/logstash-plain.log``  
RSyslog VM  
``ssh vm1  
systemctl restart rsyslog
journalctl -f``  

### Check your ports  
From VM with rsyslog in ELK direction  
``nc -v -u -z -w 3 172.29.12.11 514``  

### Check logs  
From cli (or browser):  
``curl -L http://PUBLIC_IP:9200/_cat/indices``  

Go to Kibana, create ES index "logstash-\*" with time "\@timestamp"  

### Finalization  
That's it! Now we have our logs in pretty Kibana with mighty ES backend. On the next week I'll tell how to export logs from OpenStack LXC containers and how to automate the configuration. See ya!  
