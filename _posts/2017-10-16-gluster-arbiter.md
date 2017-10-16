---
layout: post
title: Glusterfs replica + arbiter
tags: gluster linux
---
### Glusterfs replica 2+1


### Intro
Today we will discuss about glusterfs on two storage nodes with one management node aka arbiter scheme.  
If you have only two cool hardware nodes and you want some nice HA in your storage, then arbiter scheme is what you need.  
In case of failure this scheme is working like this:
1) When one of your storage node goes down then no one will suspect something.  
2) Same behaviour if arbiter goes down.  
3) If arbiter node and storage node are down, then your gluster cluster becomes readonly.  
4) With two storage nodes in down state your transport point will be unavailable.  
Also with this arbiter scheme you will always have quorum in write mode so you can be sure that your data is consistent.    

### How to deploy  
What we have:  
- 3 ubuntu 16.04 nodes
``cat /etc/hosts  
storage-1 10.1.39.100  
storage-2 10.1.39.101  
meta-1 10.1.39.102``  

_Run on all nodes_  
``sudo passwd root  
add-apt-repository ppa:gluster/glusterfs-3.12  
apt update  
apt install glusterfs-server  
gluster peer probe storage-{1..2}; gluster peer probe meta-1  
mkdir /mnt/gluster-brick  
mkdir /opt/gluster-data  
gluster volume create data replica 3 arbiter 1 transport tcp storage-1:/mnt/gluster-brick storage-2:/mnt/gluster-brick   meta-1:/mnt/gluster-brick  
gluster volume start data  
gluster volume info``  

_client_  
``mount -t glusterfs storage-1/data MOUNTDIR``  
