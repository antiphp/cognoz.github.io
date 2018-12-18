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
So, we need to manually create disk partitions and prepare them for bluestore osds  
We will use 2 partitons per disk - one for osd data and one raw block device for bluestore (without seperate db/wal partitions). In this example, our target device is /dev/sdd with osd-id=6.   
##### Step 1. Remove old osd.  
``ceph osd out 6
ceph osd rm 6
ceph auth del osd.6
ceph osd crush rm osd.6``  
Wait for rebalance, and then it will be done, umount /var/lib/ceph/osd/ceph-6 dir, and zap everything  
``umount  /var/lib/ceph/osd/ceph-6
sgdisk -Z /dev/sdd``  

##### Step 2. Partitions, dirs.  
``sgdisk --new=1:0:+1GB --change-name=1:osd_data_6 --partition-guid=1:$(uuidgen) --mbrtogpt -- /dev/sdd
sgdisk --largest-new=2 --change-name=2:bluestore_block_6 --partition-guid=2:$(uuidgen) --mbrtogpt -- /dev/sdd
mkfs -t xfs -f -i size=2048 -- /dev/sdd1
ceph osd create
mkdir /var/lib/ceph/osd/ceph-6  
chown -R ceph:ceph /var/lib/ceph/osd/ceph-6/ /dev/sdd*``

##### Step 3. Creating keys, fsid, adding osd.
``ceph-osd --setuser ceph -i 6 --mkkey --mkfs #VERY IMPORTANT!!! (maybe you need to delete some block/fsid/keyrings there)  
ceph auth add osd.6 osd 'allow *' mon 'allow rwx' mgr 'allow profile osd' -i /var/lib/ceph/osd/ceph-6/keyring
ceph osd crush add 6 0.05 host=node-61``  

##### Step 4. Modifying CRUSH. Modifying UDEV. Starting osd.  
``ceph osd getcrushmap -o ma-crush-map
crushtool -d ma-crush-map -o ma-crush-map.txt
vim ma-crush-map.txt   
crushtool -c ma-crush-map.txt -o ma-crush-new-map  
vim /etc/udev/rules.d/99-ceph.rules #IMPORTANT
          KERNEL=="sdd*", SUBSYSTEM=="block", ENV{DEVTYPE}=="partition", OWNER="ceph", GROUP="ceph", MODE="0660"
          ENV{DM_LV_NAME}=="osd-*", OWNER="ceph", GROUP="ceph", MODE="0660"
start ceph-osd id=6``  
I hope that everything in your env went smooth and nice!   
