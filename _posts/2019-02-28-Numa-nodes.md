---
layout: post  
title: NUMA tutorial
tags: NUMA linux
---


### Intro  
Several commands for NUMA administration       


### Instructions  
Verify that your processor is supporting NUMA  
``dmesg | grep -i numa``  

Install numactl  
``apt -y install numactl``  

List cpu features  
``lscpu | grep -i numa``  

Find out pid of process to pin  
``ps aux | grep ceph-osd``  

Get current cores assertion  of process  
``ps -mo psr -p $pid``  

List NUMA topology  
``numactl --hardware``
(Bear in mind that hyperthreading can make things much worse)  

PIN process to cores via daemon  
vim /usr/lib/systemd/system/ceph-osd  
``/usr/lib/systemd/system/ceph-radosgw\@.service``  
or via NUMACTL  
``numactl --cpunodebind=1 --membind=1 ceph-osd``  

Check  
``taskset -pc $(pgrep ceph-osd) ; done``  
