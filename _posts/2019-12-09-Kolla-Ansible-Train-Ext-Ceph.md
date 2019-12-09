---
layout: post  
title: Deploying Kolla-Ansible release Train with Ext Ceph  
tags: linux ceph ansible openstack kolla kolla-ansible
---


### Intro  
Mission: Deploy Kolla-ansible release Train with 1 controller, 2 computes and external Ceph (business purpose - test bug with live-migration in Train);     

### Prerequisites  
- Working Ceph (3 nodes) within same network and root access;    
- 3 VM for Openstack env (for test, 8 cpu/12ram/100GB local + 3 network interfaces(mgmt/storage/external));    
- Deployment VM Ubuntu 18 (1 cpu/1ram/30GB);     

### Deployment   
#### Prepare deployment host  
SSH to deployment VM and begin:  
``cd /opt
git clone https://github.com/openstack/kolla-ansible.git
cd kolla-ansible
git checkout stable/train  
apt update; apt -y install virtualenv  
virtualenv /opt/venv
source /opt/venv/bin/activate  
pip install -r requirements.txt
pip install ./ #install kolla-ansible package
mkdir -p /etc/kolla
chown $USER:$USER /etc/kolla
cp -r etc/kolla/* /etc/kolla
cp ansible/inventory/* .``     

### Prepare target hosts  
1. Configure all network interfaces (for data plane and control)  
2. Install python-minimal  
3. Configure passwordless access from deploymen VM
4. You need either raw block devices or configure VG (pvcreate,vgcreate..) for OSD's
5. If you want to use raw block devices, you need to create partitions there via gdisk or analog.
6. Configure group_vars/osds.yml group_vars/all.yml  

So, lets start.  
#### Configuration of interfaces    
cat /etc/netplan/01-netcfg.yaml  
``network:
  version: 2
  renderer: networkd
  ethernets:
    ens160:
      addresses: [ 10.220.104.54/24 ]
      gateway4: 10.220.104.254
      nameservers:
          addresses:
              - "8.8.8.8"
    ens192:
      addresses: [ 10.220.103.54/24 ]
    ens224:
      addresses: [ 10.220.101.54/24 ]``  
netplan apply  

#### Install python-minimal  
``apt update; apt -y install python-minimal``  

#### Configure passwordless access  
deployhost:  
``ssh-keygen;  
cat /root/.ssh/id_rsa.pub (copy in buffer)``  
target1-3:  
`` echo $(key) >> /root/.ssh/authorized_keys``  

#### Don't forget to enable hardware virtualization  
On compute nodes verify:  
``grep -r vmx /proc/cpuinfo``

#### Also, check that nova user exists in Ceph, or create it  
``ceph auth list;
 ceph auth add client.nova
 ceph auth caps client.nova mon 'profile rbd' osd 'profile rbd pool=images, profile rbd pool=vms, profile rbd pool=volumes, profile rbd pool=backups'``  

#### Create files for ceph integration in /etc/kolla/config (without cinder-backup)  
``mkdir -p /etc/kolla/config/{nova,cinder,glance}``  
tree /etc/kolla/config/  
``.
├── cinder
│   ├── ceph.conf
│   ├── cinder-volume
│   │   └── ceph.client.cinder.keyring
│   └── cinder-volume.conf
├── glance
│   ├── ceph.client.glance.keyring
│   ├── ceph.conf
│   └── glance-api.conf
└── nova
    ├── ceph.client.cinder.keyring
    ├── ceph.client.nova.keyring
    ├── ceph.conf
    └── nova-compute.conf``    
paste there keyrings, ceph.conf from ceph and other stuff, more info here -
https://docs.openstack.org/kolla-ansible/queens/reference/external-ceph-guide.html  

#### Generate passwords  
``kolla-genpwd``  
Optionally, change keystone_admin_password there to something shorter for convenience;  

#### Configure variables  
vim /etc/kolla/globals.yml  
[/etc/kolla/globals.yml]({{"/listings/2019-12-09-Kolla-Ansible-Train-Ext-Ceph/globals.yml"}})  
vim /opt/kolla-ansible/multinode
[/opt/kolla-ansible/multinode]({{"/listings/2019-12-09-Kolla-Ansible-Train-Ext-Ceph/multinode"}})    

#### Other checks  
In inventory file (multinode, for example), your nodes also should be placed under [baremetal:children] section (bootstrap).  

#### Bootstrap  
``kolla-ansible -i multinode bootstrap-servers``  

#### Deploy  
``kolla-ansible deploy -i multinode``  

#### Post-Deploy  
``kolla-ansible post-deploy``  

#### Check basic stuff  
If you installed kolla in venv, u also need openstack clients.  
``apt install -y build-essential python-dev
source /opt/venv/bin/activate
pip install openstackclient``  
Now, check basic statuses:  
``cinder service-list; nova service-list; neutron agent-list``  

### Links  
