---
layout: post  
title: Leveraging VMware Vsphere API via Pyvmomi library  
tags: vmware vsphere api python tools
---


### Intro  
Mission: Automate several actions in vmware cluster via python pyvmomi library.    
Case: Delete/Create/Update several VM's. Create/Delete/Revert to snapshots, etc...      

### Prerequisites  
- VMware vsphere cluster;  
- Admin access to vsphere cluster (optional);  
- Linux VM for pyvmomi code execuiton;     

### Overview  
We need to clone 2 github repositories and install several pip packages.  

### Installation  
SSH to our Linux VM and start:  
``bash
mkdir /opt/vmware; cd /opt/vmware;  
git clone https://github.com/vmware/pyvmomi.git
git clone https://github.com/vmware/pyvmomi-community-samples.git
apt install virtualenv -y
virtualenv /opt/venv;
source /opt/venv/bin/activate
cd /opt/vmware/pyvmomi/
git tags; #choose latest stable tag  
git checkout v6.7.1
pip install -r requirements.txt
python setup.py install``  
Now, we have pyvmomi installed on our machine and we are free to do some api magic via community samples.  
For example I need to delete several machines and I'd like to do it without slow VMware UI :)  
( If you are working on a public vm consider using one of Linux CLI vaults)  
``bash
cd /opt/vmware/pyvmomi-community-samples/samples;  
for vm in prom1 prom2 grafana1 grafana2; do
python destroy_vm.py -s VSPHERE_IP -u VSPHERE_USER -p VSPHERE_PASSW -v $vm``  

That's all!  
See you space cowboy...  
