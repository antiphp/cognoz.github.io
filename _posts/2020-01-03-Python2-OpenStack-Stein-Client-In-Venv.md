---
layout: post  
title: Installing Stein OpenStack clients in python2.7 venv in 2020 year  
tags: python venv openstack
---


### Intro  
Mission: Install OpenStack clients in pythno2.7 venv in the year 2020    
Why bother: Because of cmd2/more-itertools and other python3 deps you can't just run "pip install python-openstackclient".     

### Prerequisites  
- Linux machine (I use centos 7.8);     

### Overview  
- Install packages for pip/venv/gcc etc;  
- Create venv;  
- Create file with correct deps;  
- Install;  
- Enjoy;  

### Installation  
SSH to our Linux VM and start:  
``bash  
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
yum -y install gcc libattr-devel.x86_64 python-devel.x86_64
pip install virtualenv
virtualenv -p python2 /opt/venv``  
Now we need to create file  with right deps for pip packages   
vim list_deps_os_client
``bash
cmd2==0.8.9
more-itertools==5.0.0
msgpack==0.6.2
python-cinderclient==5.0.0
python-dateutil==2.8.1
python-glanceclient==2.17.0
python-keystoneclient==3.22.0
python-novaclient==16.0.0
python-openstackclient==3.14.0
pytz==2019.3
pyudev==0.21.0
pyxattr==0.5.1
PyYAML==5.2``  

Install stuff
``bash
source /opt/venv/bin/activate  
pip install -r list_deps_os_client``  
