---
layout: post
title: Simple glusterfs FIO Benchmarking
tags: gluster benchmarking fio  
---
### Benchmarking glusterfs/ganesha-nfs cluster with fio  
Simple benchmarking of gluster cluster with nfs-ganesha export and FIO tester.  

### Components:
- Two VMs in Openstack, CentOS 7.2:
_test-nfs-rk-2 10.1.39.208  
test-nfs-rk-4 10.1.39.213  
test-nfs-rk-3 10.1.39.209_  
- glustefs version: 3.12.1  
- Benchmarking VM, ubuntu 16.04:  
_test-fio-1  10.1.39.214_  

## Step 1. Initial configuration of VM
_RUN on all VMs_  
``cat /etc/hosts  
127.0.0.1 test-fio-rk  
10.1.39.207 test-nfs-rk-1
10.1.39.208 test-nfs-rk-2
10.1.39.209 test-nfs-rk-3
10.1.39.213 test-nfs-rk-4
10.1.39.211 test-nfs-rk-1v
10.1.39.212 test-nfs-rk-2v
10.1.39.214 test-fio-rk
``    
_RUN on test-fio node_  
``add-apt-repository ppa:gluster/glusterfs-3.12  
apt update  
apt -y install git make gcc zlib1g-dev glusterfs-client  libaio-dev nfs-common  
git clone https://github.com/axboe/fio.git  
cd fio  
./configure  
make  
make install``  

## Step 2. Benchmarking via gluster endpoint  
``mkdir /opt/gluster_mountpoint  
mount -t glusterfs 10.1.39.240:cluster-demo /opt/gluster_mountpoint``  
random    
``fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/opt/gluster_mountpoint/test_gluster --bs=4k --iodepth=64 --size=1G --readwrite=randwrite``  
seqwrite    
``fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/opt/gluster_mountpoint/test_gluster --bs=4k --iodepth=64 --size=1G --readwrite=write``  
seqread  
``fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/opt/gluster_mountpoint/test_gluster --bs=4k --iodepth=64 --size=1G --readwrite=read``   
``rm -rf /opt/gluster_mountpoint/test_gluster``  

## Step 3. Benchmarking via nfs-ganesha endpoint  
``mkdir /opt/nfs_endpoint  
mount -t nfs 10.1.39.211:/testshet /opt/nfs_endpoint``  
random  
``fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/opt/nfs_mountpoint/test_nfs --bs=4k --iodepth=64 --size=1G --readwrite=randwrite``   
seqwrite  
``fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/opt/nfs_mountpoint/test_nfs --bs=4k --iodepth=64 --size=1G --readwrite=randwrite``   
seqread  
``fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/opt/nfs_mountpoint/test_nfs --bs=4k --iodepth=64 --size=1G --readwrite=randwrite``   
``rm -rf /opt/nfs_mountpoint/test_nfs``  
