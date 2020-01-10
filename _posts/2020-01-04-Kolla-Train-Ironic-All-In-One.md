---
layout: post  
title: Deploying Kolla Openstack release Train with Ironic on 1 baremetal node
tags: kolla openstack ironic centos swift docker registry
---


### Intro  
Mission: Deploy Openstack Kolla (release Train) with Ironic on 1 baremetal node with installed CentOS 7.   
Why not Bifrost: We need all core openstack services (like nova/glance/neutron etc) and ability to use this baremetal node not only as Ironic controller but as normal AIO environment for infra instances (like nexus/gitlab/jenkins/etc vm's).  
Why Train: Right now (end 2019/beginning of 2020 ) we usually deploy release Stein. But Ironic Stein have some bugs like https://bugs.launchpad.net/kolla-ansible/+bug/1843067. So we decided to go with Train instead ;)    

### Prerequisites  
- Baremetal server with preinstalled OS (I use centos 7.8);
Of course you can use a VM instead of baremetal. But keep in mind that AIO functionality requires a lot of resources (cpu/ssd/ram/etc..);    
- Internet or private registry/repositories with all images/packages;    


### Overview  
- Install packages via yum like docker-ce/virtualenv;  
- Create venv;  
- Install a lot of pip stuff in venv;  
- Install kolla/kolla-ansible in venv;     
- Build images on remote machine;
- Copy registry with images from remote machine to dest node;  
- Configure kolla's ymls;  
- Configure disk/disks/partitions for Swift;  
- Change Swift task with hardcoded partition (If you don't have a dedicated device for Swfit, overwise use community's swift preparation instruction);  
- Configure rings for Swift;
- Bootstrap / Deploy /Post-deploy;    

### Packages installation  
``curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
yum -y install git gcc libattr-devel.x86_64 python-devel.x86_64 #mostly for further installation of openstack's clients
pip install virtualenv``  

### Venv  
``virtualenv /opt/venv  
source /opt/venv/bin/activate``  

### Building images on remote machine   
Optional step. Plan is to build images on a machine with a good internet connection, run locally docker registry, push images to it and export result registry container with all images to target host from which kolla will be deployed. Machine OS is CentOS7.     
``cd /opt
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
yum -y install git gcc libattr-devel.x86_64 python-devel.x86_64
pip install virtualenv
virtualenv /opt/kolla_train
cd /opt/kolla_train
git clone https://github.com/openstack/kolla-ansible.git -b stable/train
git clone https://github.com/openstack/kolla.git -b stable/train
cd kolla-ansible
pip install -r requirements.txt  #I hope that you do all of this in virtual env)  
pip install ./
cd ../kolla
pip install -r requirements.txt  
pip install ./
pip install tox
tox -e genconfig
cp -r etc/* /etc/
vim /etc/kolla/kolla-build.conf
#[DEFAULT]/regex - change it accordingly to your needs (I use regex:
"regex = "fluentd|nova-.*|ironic-.*|neutron-.*|glance-.*|placement-.*|heat-.*|horizon|keystone-.*|swift-.*|openvswitch-.*|kolla-toolbox|mariadb|haproxy|dnsmasq|cron|iscsid|memcached|rabbitmq|keepalived|chrony"" for all needed images)    
kolla-build``  
Now, run local docker registry  and push there all builded images  
``docker run -d -p 5002:5000 --restart always --name kolla-registry registry:2``   

Next, you can copy docker registry volume dir to your dest host with kolla-ansible and run local registry there  
``cd /var/lib/docker/volumes/
tar -cjf $ID.tar $ID  
scp $ID.tar root@$DEST-HOST-IP:  
ssh root@$DEST-HOST-IP  
docker run -d -p 5002:5000 --restart always --name kolla-registry registry:2
docker inspect kolla-registry | grep volume #memorize ID  
docker stop kolla-registry  
yum install -y bzip2 #just in case
tar -xf $ID.tar  
mv $ID/_data/* /var/lib/docker/volumes/$CURRENT_VOL/_data/
docker start kolla-registry``  
Okay, now we have registry on right node with all images in place.    

### Git repos  
``cd /opt
git clone https://github.com/openstack/kolla-ansible.git -b stable/train
git clone https://github.com/openstack/kolla.git -b stable/train
cd kolla-ansible
pip install -r requirements.txt  #I hope that you do all of this in virtual env)  
pip install ./
cd ../kolla
pip install -r requirements.txt  
pip install ./
pip install ansible==2.8 #I used this version for queens - train releases ``    

### Configuration  
Next, we need to configure globals.yml and inventory file;  
We will use default all-in-one inventory and enable/disable services deployment via
globals.  
``cp -r /opt/kolla-ansible/etc/* /etc/
kolla-genpwd
vim /etc/kolla/globals.yml``  
[globals.yml]({{"/listings/2020-01-04-Kolla-Train-Ironic-All-In-One/globals.yml"}})    

### Swift stuff
#### Partition workaround
!!!WARNING!!!
If you have a dedicated device for swift - use community docs instead - https://docs.openstack.org/kolla-ansible/train/reference/storage/swift-guide.html)
!!!WARNING!!!  

First of all, it's sad but all I had was 300+ free space on the single sda disk.  
So I needed to create a new partition on this disk named and labeled it and everything should go fine.    
Kolla's instruction doesn't presume this case, and I didn't managed to name partition correctly (not just to label it).      
So I workarounded this problem with little hardcode in Swift ansible task (hate this but I was really-really short of time and it was holidays after all)  
So let's begin with a new partition and xfs filesystem:      
``fdisk /dev/sda
n
p
2
3145730048-3904897023
3904897023
w``  
Create xfs:  
``mkfs.xfs -f -L 'KOLLA_SWIFT' /dev/sda2``  
Now we hardcode our sda2 device in swift lookup task:  
``blkid | grep sda2  #get UUID``    
vim /opt/venv/share/kolla-ansible/ansible/roles/swift/tasks/start.yml  
#pay attention to first 30 lines  
[start.yml]({{"/listings/2020-01-04-Kolla-Train-Ironic-All-In-One/start.yml"}})  

#### Ring creation  
Again and again. Kolla-ansible still doesn't capable to create Swift rings on itself.  
It's time for the BASH  
I created script file for this purpose. I used this instruction https://docs.openstack.org/kolla-ansible/train/reference/storage/swift-guide.html and changed there some numbers (AIO with one partition):  
Source:  
[generate_swift_rings.sh]({{"/listings/2020-01-04-Kolla-Train-Ironic-All-In-One/generate_swift_rings.sh"}})   

### Ironic  
#### Get images  
``mkdir  /etc/kolla/dt-1/ironic
cd /etc/kolla/dt-1/ironic
wget ironic-agent.initramfs
wget ironic-agent.kernel``  
#### Configs  
#Be carefull with the path - do not paste configs in config dir)  
vim /etc/kolla/dt-1/ironic.conf
[ironic.conf]({{"/listings/2020-01-04-Kolla-Train-Ironic-All-In-One/ironic.conf"}})    
vim /etc/kolla/dt-1/ironic-inspector.conf   
[ironic-inspector.conf]({{"/listings/2020-01-04-Kolla-Train-Ironic-All-In-One/ironic-inspector.conf"}})    

### Deploy
``kolla-ansible -i /etc/kolla/dt-1.inv deploy
kolla-ansible -i /etc/kolla/dt-1.inv post-deploy``  

### Post-deploy  
First of all, its possible that swift containers will get "permission denied" from mounted storage (you can check this in /var/log/kolla/swift/.. log after object container creation (openstack container create test)). In that case, do:  
``chmod 777 -R /srv/node/  #wrong permissions for swift  
docker ps | grep swift | awk '{print $1}' | xargs -n1 docker stop
docker ps -a | grep swift | awk '{print $1}' | xargs -n1 docker start
mount | grep sda2``  
Second, Kolla doesn't do swift temp-url for glance. Hence, if you try to deploy node via baremetal service, you will get 'An auth plugin is required to determine endpoint URL' (bug: https://bugs.launchpad.net/kolla-ansible/+bug/1741950). To fix it you need to configure swift endpoints in ironic-conductor and configure temp-url key in swift ironic account:  
Get account info:  
``source code/openrc-dt1
export OS_PROJECT_NAME=service
export OS_USERNAME=ironic
export OS_PASSWORD=pass
openstack object store account show``  
Set temp-url key:  
``source code/openrc-dt1
export OS_PROJECT_NAME=service
export OS_USERNAME=ironic
export OS_PASSWORD=B5OnAJHYoRq1OuCy5rgUtAODidBTuQyaUQAi8PaR
openstack object store account set --property Temp-Url-Key=0e827e0e497dc06dc35e8000``  
Fill this data in ironic-conductor conf:  
vim /etc/kolla/ironic-conductor/ironic.conf  
``bash
[glance]  
swift_account = AUTH_e75374a7e3b14b2f9c4e9c9ec4f7119a
swift_api_version = v1
swift_container = glance
swift_endpoint_url = http://10.101.166.200:8080
swift_temp_url_key = 0e827e0e497dc06dc35e8000``  
Restart all ironic containers:  
``docker ps | grep ironic | awk '{print $1}' | xargs -n1 docker restart``  


### other stuff  (optional)  
#### Reconfigure env  
``kolla-ansible -i /etc/kolla/dt-1.inv reconfigure --tags ironic``  

#### Deploy only one service  
``kolla-ansible -i /etc/kolla/dt-1.inv deploy --tags mariadb,nova``  
