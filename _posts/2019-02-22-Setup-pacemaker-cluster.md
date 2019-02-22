---
layout: post  
title: Setup pacemaker CentOS cluster with drbd
tags: linux pacemaker drbd centos  
---


### Intro  
Always forget this stuff)  


### Instructions  
2 VM with Centos 7  

NTP and timezones   
``yum install ntpdate``  
crontab -e  
``0 0 * * * /usr/sbin/ntpdate ru.pool.ntp.org``  
``cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime  
ntpdate ru.pool.ntp.org``

Firewall     
``firewall-cmd --permanent --add-service=high-availability
firewall-cmd --permanent --add-port=7788/tcp
firewall-cmd --reload``  

Packages  
``rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo clean metadata
yum update  
yum install pacemaker pcs resource-agents  
passwd hacluster  
systemctl enable pcsd
systemctl start pcsd``  

Auth  
``pcs cluster auth node1 node2 -u hacluster``  

Cluster setup   
``pcs cluster setup --force --name NLB node1 node2
pcs cluster enable --all
pcs cluster start --all``  

Disable stonith and quorum (in case of 2 nodes)  
``pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore``  

VIP  
``pcs resource create virtual_ip ocf:heartbeat:IPaddr2 ip=IP cidr_netmask=24 op monitor interval=60s``  

DRBD  packages and modules  
``yum install kmod-drbd84 drbd84-utils  
modprobe drbd  
echo drbd > /etc/modules-load.d/drbd.conf``  

DRBD share  
vim /etc/drbd.d/r0.res
``resource r0 {
protocol C;
startup {
wfc-timeout  15;
degr-wfc-timeout 40;
}
net {
cram-hmac-alg sha1;
shared-secret "b5eb86aa76a6136";
}
on centos-ansible {
address 10.220.106.83:7788;
device /dev/drbd0;
disk /dev/sdb;
meta-disk internal;
}
on centos-ansible2 {
address 10.220.106.85:7788;
device /dev/drbd0;
disk /dev/sdb;
meta-disk internal;
}``  
on both  
``drbdadm create-md r0``  
on one node:  
``drbdadm primary testdata1 --force``    
mkfs  
``mkfs.ext3 /dev/drbd0``  

DRBD Pacemaker  
``pcs cluster cib drbd_cfg
 pcs -f drbd_cfg resource create DrbdData ocf:linbit:drbd drbd_resource=testdata1 op monitor interval=60s
 pcs -f drbd_cfg resource master DrbdDataClone DrbdData master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
 pcs cluster cib-push drbd_cfg``  

 DRBD FS  
 ``pcs cluster cib fs_cfg
pcs  -f fs_cfg resource create DrbdFS Filesystem device="/dev/drbd0" directory="/mnt" fstype="ext3"  
pcs  -f fs_cfg constraint colocation add DrbdFS with DrbdDataClone INFINITY with-rsc-role=Master
pcs  -f fs_cfg constraint order promote DrbdDataClone then start DrbdFS
pcs cluster cib-push fs_cfg``  
Check  
``pcs status``  
