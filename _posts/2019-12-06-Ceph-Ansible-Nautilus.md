---
layout: post  
title: Deploying ceph-ansible release Nautilus (bluestore dedicated)
tags: linux ceph ansible ceph-ansible  
---


### Intro  
Mission: Deploy ceph-ansible for further Openstack deployment. 3 hosts with collocated mons and osds.  

### Prerequisites  
3 VM Ubuntu 18 (for test, 4 cpu/4ram/2 osd*150GB + 1 osd*10GB/2 network interfaces(data net and mgmt one))  
Deployment VM Ubuntu 18 (1 cpu/1ram/30GB)     

### Deployment   
#### Prepare deployment host  
SSH to deployment VM and begin:  
``cd /opt
git clone https://github.com/ceph/ceph-ansible.git
cd ceph-ansible
git checkout stable-4.0 #or you can use any tag, like v4.0.5  
apt update; apt -y install virtualenv  
virtualenv /opt/venv
source /opt/venv/bin/activate  
pip install -r requirements.txt
``  
Also, you need to configure group_vars/osds.yml group_vars/all.yml:  
cd /opt/ceph-ansible/  
vim group_vars/osds.yml (Pay attention to partition/device setup)    
[group_vars/osds.yml]({{"/listings/2019-12-06-Ceph-Ansible-Nautilus/osds.yml"}})  
vim group_vars/all.yml  
[group_vars/all.yml]({{"/listings/2019-12-06-Ceph-Ansible-Nautilus/all.yml"}})  


### Prepare target hosts  
1. Configure all network interfaces (for data plane and control)  
2. Install python-minimal  
3. Configure passwordless access from deploymen VM
4. You need either raw block devices or configure VG (pvcreate,vgcreate..) for OSD's
5. If you want to use raw block devices, you need to create partitions there via gdisk or analog.

So, lets start.  
#### Configuration of interfaces    
cat /etc/netplan/01-netcfg.yaml  
``network:
  version: 2
  renderer: networkd
  ethernets:
    ens160:
      addresses: [ 10.220.104.52/24 ]
      gateway4: 10.220.104.254
      nameservers:
          addresses:
              - "8.8.8.8"
    ens192:
      addresses: [ 10.220.103.52/24 ]``  
netplan apply  

#### Install python-minimal  
``apt update; apt -y install python-minimal``  

#### Configure passwordless access  
deployhost:  
``ssh-keygen;  
cat /root/.ssh/id_rsa.pub (copy in buffer)``  
target1-3:  
`` echo $(key) >> /root/.ssh/authorized_keys``  

#### Prepare hosts file  
cat hosts    
``[mons]
10.220.104.50
10.220.104.51
10.220.104.52

[osds]
10.220.104.50
10.220.104.51
10.220.104.52

[grafana-server]
10.220.104.50
10.220.104.51
10.220.104.52``  

#### Check existing block devices  
``ansible -m shell -a 'lsblk' -i hosts '*'``  

#### Configure partitions on devices  
We will use sdb and sdc disks as data osd, and sdd(two partitions, each 5GB) as db/wal device for osd:
``ansible -m shell -a 'apt update; apt -y install gdisk' -i hosts '*'
ansible -m shell -a '(echo n;echo p;echo 1;echo;echo;echo;echo w;echo Y) | gdisk /dev/sdb;(echo n;echo p;echo 1;echo;echo;echo;echo w;echo Y) | gdisk /dev/sdc;(echo n;echo p;echo 1;echo;echo 10485743‬;echo;echo w;echo Y)| gdisk /dev/sdd;(echo n;echo p;echo 2;echo;echo;echo;echo w;echo Y) | gdisk /dev/sdd' -i hosts '*'``  

#### Check existing block devices  
``ansible -m shell -a 'lsblk' -i hosts '*'``  

### Deploy  
``cd /opt/ceph-ansible  
cp site.yml.sample site.yml  
ansible-playbook -vv -i hosts site.yml``  

#### If something goes wrong  
Ad-hoc commands:  
Wipe all devices (ceph):  
``ansible -m shell -a 'ceph-volume lvm zap /dev/sdb --destroy;ceph-volume lvm zap /dev/sdc --destroy;ceph-volume lvm zap /dev/sdd --destroy;' -i hosts '*'``  
Wipe all partitions:  
``ansible -m shell -a "(echo d; echo w; echo Y)| gdisk /dev/sdb;(echo d; echo w; echo Y)| gdisk /dev/sdc(echo d; echo w; echo Y)| gdisk /dev/sdd;" -i hosts '*'``  

#### bugs  
At some point, after multiple deploys/wipes,  I got an environment with 2/6 osds are being down. Fix was pretty simple - reboot.  
Also, I didn't manage to deploy block.db/wal for several disks to one partition (though it was easy accomplished with ceph-ansible version 3...)     
