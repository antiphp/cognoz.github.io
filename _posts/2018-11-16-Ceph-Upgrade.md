---
layout: post  
title: Ceph Upgrade on OpenStack Kilo (Firefly -> Luminous) (Ubuntu Trusty)  
tags: linux ceph
---

#### Draft scheme - How to upgrade ceph cluster from Firefly release(ver. 0.8 Mirantis MOS7 build) to Luminous.  

!!!!!!!!!!!!!!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
This instruction has NOT tested yet! It's more like a draft scheme.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#### Plan  
Firefly -> Jewel (Flags,Rebalance) -> Luminous -> MGR's deploy -> Filestore to Bluestore transition (Rebalance)  
#### Set noout flags  
(Dont sure)  
``ceph osd set noout
ceph osd set nobackfill
ceph osd set norecover``

#### Upgrade packages on MON  
``mkdir -p ceph_upgrade/apt-lists/
mv /etc/apt/sources.list.d/mos* ceph_upgrade/apt-lists/
apt update
apt -y install python-pip
pip install --upgrade pip
apt remove -y ceph-deploy
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
apt-add-repository 'deb https://download.ceph.com/debian-jewel/ trusty main'
apt update
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install ca-certificates apt-transport-https
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install -o Dpkg::Options::=--force-confnew ceph-mon radosgw
stop ceph-mon-all
chown -R ceph:ceph /var/lib/ceph
chown -R ceph:ceph /var/log/ceph
start ceph-mon-all``  

#### Upgrade packages on OSD  
``mkdir -p ceph_upgrade/apt-lists/
mv /etc/apt/sources.list.d/mos* ceph_upgrade/apt-lists/
apt update
apt -y install python-pip
pip install --upgrade pip
apt remove -y ceph-deploy
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
apt-add-repository 'deb https://download.ceph.com/debian-jewel/ trusty main'
apt update
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install ca-certificates apt-transport-https
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install -o Dpkg::Options::=--force-confnew ceph-osd
stop ceph-osd-all
chown -R ceph:ceph /var/lib/ceph
chown -R ceph:ceph /var/log/ceph
for ID in $(ls /var/lib/ceph/osd/|cut -d '-' -f 2); do stop ceph-osd id=$ID; start ceph-osd id=$ID; done``

#### Upgrade Compute nodes  
``for instance_id in 1 2 3 4; do nova live-migrate $instance_id; done
mkdir -p ceph_upgrade/apt-lists/
mv /etc/apt/sources.list.d/mos* ceph_upgrade/apt-lists/
apt update
apt -y install python-pip
pip install --upgrade pip
apt remove -y ceph-deploy
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
apt-add-repository 'deb https://download.ceph.com/debian-jewel/ trusty main'
apt update
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install ca-certificates apt-transport-https
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install -o Dpkg::Options::=--force-confnew ceph
``

#### Update crush table  
It WILL affect cluster. Someone says that it can affect up to 50% of your data.  
``ceph osd crush tunables optimal
ceph osd set require_jewel_osds
ceph osd set sortbitwise``

Wait for end of recovery  
``watch 'ceph -s | egrep "recovery| degraded"'``

#### Upgrading MON Jewel to Luminous, creating MGR    
``sed -i 's/.*jewel.*//g' /etc/apt/sources.list
apt-add-repository 'deb https://download.ceph.com/debian-luminous/ trusty main'
apt update
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install -o Dpkg::Options::=--force-confnew ceph-mon
stop ceph-mon-all
start ceph-mon-all
mkdir -p /var/lib/ceph/mgr/ceph-$(hostname -s)
ceph auth get-or-create mgr.$(hostname -s) mon 'allow profile mgr' osd 'allow *' mds 'allow *'>>/var/lib/ceph/mgr/ceph-$HOSTNAME/keyring
start ceph-mgr id=$(hostname -s)
iptables -I INPUT -p tcp --match multiport --dports 6800:7300 -m comment --comment "ceph-mgr ports" -j ACCEPT
iptables -I INPUT -p tcp --dport 7000 -m comment --comment "ceph-mgr dashboard port" -j ACCEPT
service iptables-persistent save``
Now you can check status of your cluster in Web UI on
http://public-ip-of-your-active-mgr:7000  

#### Upgrading OSD Jewel to Luminous  
``sed -i 's/.*jewel.*//g' /etc/apt/sources.list
apt-add-repository 'deb https://download.ceph.com/debian-luminous/ trusty main'
apt update
ceph osd set noout
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install -o Dpkg::Options::=--force-confnew ceph-osd  
for ID in $(ls /var/lib/ceph/osd/|cut -d '-' -f 2); do stop ceph-osd id=$ID; start ceph-osd id=$ID; done``

#### Upgrading CMP Jewel to Luminous
Dont sure if we needed to migrate VM to other hosts....
I heard that Jewel librbd should be compatible with the Luminous release....
``sed -i 's/.*jewel.*//g' /etc/apt/sources.list
apt-add-repository 'deb https://download.ceph.com/debian-luminous/ trusty main'
apt update
env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install -o Dpkg::Options::=--force-confnew ceph``

#### Upgrading osd with Filestore to Bluestore  
Ceph-volume command is incompatible with Ubuntu Trusty  [issue](https://tracker.ceph.com/issues/23496)  
So, right now i don't have any ideas about this process....
