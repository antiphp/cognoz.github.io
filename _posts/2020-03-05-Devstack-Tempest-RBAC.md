---
layout: post  
title: Testing OpenStack RBAC (policy based) with DevStack and Patrole project
tags: openstack devstack rbac policy patrole
---

### Intro  
Mission: Deploy DevStack release Queens on Virtual Machine (VirtualBox; Centos 7) and test custom roles/policies with Patrole project.  

### Prerequisites  
- Check that hardware virtualization is enabled on your workstation;  
- VM with Centos7 (I use 3cpu/6ram/30GB but for this task it could be a little overkill);
- Internet/ access to repositories (offline deploy is out of scope);

### Overview  
- Create VM with at least 2cpu/4ram/20GB and two interfaces - one for internet and other for local ssh (in VirtualBox I create two adapters - NAT and virtualbox Host-only adapter);
- Install CentOS7/8 or other modern Linux distribution on it;
- Prepare OS for devstack;
- Install DevStack;
- Install Patrole;  
- Configure Tempest;
- Run Tempest's Patrole suit with default roles;
- Configure custom policies;
- Run Tempest again and again while changing policies;

### VM creation and Linux installation  
Nothing fancy, really.

- Download latest Centos7 minimal ISO from any link suitable for you: [isoredirect.centos.org](http://isoredirect.centos.org/centos/7/isos/x86_64/);
- Create new VM in VirtualBox - Centos, 2-3cpu/4-6ram/20-40hdd/2 adapters(NAT and virtualbox host adapter), mount CentOS iso, start VM;
- Install CentOS;
- Log in your new VM via VB console;
- Configure both interfaces in /etc/sysconfig/network-scripts/ifcfg-* (just BOOTPROTO=dhcp,ONBOOT=yes,DNS1=8.8.8.8,etc..);
- Restart interfaces, check ssh connectivity to VM from your workstation, ssh to it with user/pass;

### Prepare OS for the DevStack  
This is a pretty good start point - [devstack-queens-quickstart](https://docs.openstack.org/devstack/queens/).  
Preparation:
SSH keys configuration:  
``mkdir ~/.ssh ; echo "ssh-rsa MY_HOST_PUBLIC_SSH_RSA_KEY" >> ~/.ssh/authorized_keys;``  
NTP:    
``yum -y remove ntp
yum -y install chrony git screen
systemctl start chronyd
timedatectl``  
Git repos:    
``cd /opt
git clone https://opendev.org/openstack/devstack -b stable/queens
git clone http://git.openstack.org/openstack/patrole -b 0.6.0``  
Users:   
``useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack``
local.conf:  
``cd /opt/devstack``  
vim local.conf  
``[[local|localrc]]
ADMIN_PASSWORD=secret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
HOST_IP=IP_FROM_VB_HOST_NETWORK_ADAPTER
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=$DEST/data``  

### DevStack installation  
I recommend to use *screen* utility for a non-interruptible deployment.  
``cd /opt/devstack
screen -S DS-1
./stack.sh``  
Now you can relax for another 30-60 minutes and quit this screen with *CTRL+a-d*;  
If you want to re-attach to screen, execute *screen -x DS-1*;    
To enable scrolling in screen, use *CTRL-A-ESC; PgUP, PgDown*;  

#### Validate installation  
``. /opt/devstack/openrc admin admin
nova list
cinder service-list
neutron agent-list``  

### Patrole Installation  
``cd /opt/patrole
pip install .``  

### Tempest configuration  
First of all, we need to initialize new Tempest environment:  
``mkdir /opt/stack-tempest-1; cd /opt/stack-tempest-1
tempest init .
cd stack-tempest-1``  
Now you can configure tempest in etc/tempest.conf.    
Mandatory prerequisites for configuration:  
- Auth stuff (admin,password,keystone url's, domains, etc);
- Image ID (glance image-list);
- Public and private network names/ids/cidrs (neutron net-list);
- URL to sample cloud image (for example, cirros);
- Downloaded locally cloud image (for example, cirros);
- Several nova flavors;
- Cinder backend/volume-type-name (cinder type-show $typeid);

My listing is available here:  
[tempest.conf]({{"/listings/2020-03-05-Devstack-Tempest-RBAC/tempest.conf"}})

### First run on Patrole's Tempest suit  
``tempest run --regex '^patrole_tempest_plugin\.tests\.api'``  

### Replacing default policy file  
First of all, check existence of [oslo_policy] section in service  configuration. For example, for nova service  
cat /etc/nova/nova.conf  
``[oslo_policy]
policy_file = policy.yaml  #or json ``  
Next, place your policy file in /etc/nova/policy.yaml  
``cp polciy.yaml /etc/nova/policy.yaml``  
Change ownership  
``chown stack:stack /etc/nova/policy.yaml``  
Restart service  
``systemctl restart devstack@n-api.service``  

Now you can update any policy rule in this file without restarting nova-api service - changes will take effect immediately.  
