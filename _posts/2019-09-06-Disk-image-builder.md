---
layout: post  
title: Using Diskimage-builder with custom elements
tags: linux diskimage-builder  
---


### Intro  
Mission: Create custom centos/ubuntu cloud image with node-exporter and mtr-exporter for cloud SLA monitoring      

### Prerequisites  
1 VM with installed centos 7 and Internet access
Im using oracle virtualbox hypervisor with hardware acceleration and 2 nics - NAT + virtualboxhost-network  

### Deployment  
Configure basic stuff on CentOS VM  
- yum update
- ssh-keys  
- /etc/hosts
- /etc/hostname  
- packages  


``ssh centos  
cd /opt
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py  
python get-pip.py
pip install virtualenv
virtualenv venv
source venv/bin/activate
yum -y install vim python-devel kernel-devel gcc qemu-img policycoreutils-python
pip install diskimage-builder  
``  
Also, I have to install openstack clients cause my goal is to test image in the cloud, anyway.  
  ``pip install python-openstackclient==3.14.3 python-novaclient==10.1.0 python-neutronclient==6.7.0 python-keystoneclient==3.15.0 python-heatclient==1.14.0 python-glanceclient==2.10.1

vim /root/openrc
source /root/openrc
glance image-list``  

Creating basic CentOS7 image:  
``export DIB_RELEASE=centos
export DIB_DEV_USER_USERNAME='cognoz'
export DIB_DEV_USER_SHELL='/bin/bash'
export DIB_DEV_USER_PWDLESS_SUDO=true
export DIB_DEV_USER_AUTHORIZED_KEYS='/root/key.pub'
export DIB_DEV_USER_PASSWORD='testtest'
export ELEMENTS_PATH=/opt/cloud-image-and-config/images/sla-vms/elements/
disk-image-create -o centos-sla-vm.qcow2 vm centos7 install-static sla-vms
> Build completed successfully
>ls -lh
> 445M Sep  6 16:01 centos.qcow2``  
Centos7 and vm are elements (ref: https://docs.openstack.org/diskimage-builder/latest/elements/vm/README.html).  
centos7 here is for "Use CentOS 7 cloud images as the baseline for built disk images" and
vm is for "Sets up a partitioned disk (rather than building just one filesystem with no partition table)."  
sla-vms is a custom element - installs node-exporter and mtr-exporter, configs, etc..  

Test image:  
``source /root/openrc  
glance image-create --container-format bare --disk-format qcow2 --file centos.qcow2 --name centos7-1811-rk-x64 --progress

nova boot --nic net-id=85ece254-2a9e-40e5-873e-80350b80d15d --image centos7-1811-rk-x64 --key-name rk --flavor bad333a5-9b35-444f-8916-6da0a803d745 rk-dib-1  
openstack floating ip create 7a1014e5-bef7-4b3b-bdec-80d01df77eed # (ext-net-id)  
openstack server add floating ip rk-dib-1  f5fa5ee1-1c81-4277-a1f2-56157afc9387(float-id)``  

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
[rsyslog.conf]({{"/listings/2019-03-29-ELK-rsyslog/rsyslog.conf"}})  

vim /etc/rsyslog.d/22-test.conf
[22-messages.conf]({{"/listings/2019-03-29-ELK-rsyslog/22-messages.conf"}})

Install rsyslog-mmjsonparse:  
``yum install -y rsyslog-mmjsonparse``  

### Configure Logstash on ELK node  
vim /etc/logstash/conf.d/logstash.conf
[logstash.conf]({{"/listings/2019-03-29-ELK-rsyslog/logstash.conf"}})

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

Go to Kibana, create ES index "logstash-\*" with time "@timestamp"  

### Finalization  
That's it! Now we have our logs in pretty Kibana with mighty ES backend. On the next week I'll tell how to export logs from OpenStack LXC containers and how to automate the configuration. See ya!  
