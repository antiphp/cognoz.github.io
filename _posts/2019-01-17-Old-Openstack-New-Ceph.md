---
layout: post  
title: Integration of old OpenStack(Kilo) with new Ceph cluster (Luminous)  
tags: linux ceph openstack
---


### Intro  
We had one customer who wanted to deploy new Ceph cluster on two nodes, integrate them in Old Openstack Mirantis 7.0 environment and start migration process (instances, volumes, images, etc) to it.  
At first glance this task seems pretty simple - just create new cinder backend, copy new ceph.conf/keyrings and begin migration on holidays/weekend.  
But in reality, old openstack services such as glance,nova,cinder dont work with new rbd/rados in Ceph Luminous. But we found a way! So let's start.

### The problem  
Standart RBD cinder driver (cinder/volume/drivers/..) use Rados and Rbd libraries. If they outdated (as it is in our example) when driver will not be initialized (you can check it in cinder-volume log). So we need to find new libs, copy them on node, point cinder-volume service to use them, and restart service.   
### Libs  
First of all, you should find several rbd/rados libraries for openstack services. I achieved it with spare node, there I installed ceph-luminous packages. If you are using MOS7, you can download them from here:   
[libs.tar 22MB]({{"/listings/2019-01-17-Old-Openstack-New-Ceph/libs.tar.bzip2"}})  
.. class:: spoiler
list of files
``tree /opt/cool_libs/
/opt/cool_libs/
├── ceph
│   ├── compressor
│   │   ├── libceph_snappy.so
│   │   ├── libceph_snappy.so.2
│   │   ├── libceph_snappy.so.2.0.0
│   │   ├── libceph_zlib.so
│   │   ├── libceph_zlib.so.2
│   │   ├── libceph_zlib.so.2.0.0
│   │   ├── libceph_zstd.so
│   │   ├── libceph_zstd.so.2
│   │   └── libceph_zstd.so.2.0.0
│   ├── crypto
│   │   ├── libceph_crypto_isal.so
│   │   ├── libceph_crypto_isal.so.1
│   │   └── libceph_crypto_isal.so.1.0.0
│   ├── libceph-common.so
│   └── libceph-common.so.0
├── libceph-common.so
├── libceph-common.so.0
├── libcephfs.so.2
├── libcephfs.so.2.0.0
├── librados.so.2
├── librados.so.2.0.0
├── libradosstriper.so.1
├── libradosstriper.so.1.0.0
├── librados_tp.so.2
├── librados_tp.so.2.0.0
├── librbd.so.1
├── librbd.so.1.12.0
├── librbd_tp.so.1
├── librbd_tp.so.1.0.0
├── librgw.so.2
├── librgw.so.2.0.0
└── libstdc++.so.6``  
