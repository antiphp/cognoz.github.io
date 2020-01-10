---
layout: post  
title: Monitoring Process Resources Usage With Standard Linux Tools
tags: monitoring linux systemctl
---


### Intro  
Mission: Implement simple process usage monitoring via linux tools
Case: Investigate huge rss(30+GB)/cpu usage in openstack-exporter    

### Prerequisites  
- CentOS 7.6 VM with systemd    

### Overview  
We will monitor usage via simple bash script with ps/awk utils and print it to log file. Script will be started via systemd.time  

### Implementation  
SSH to target host and begin  

vim /etc/systemd/system/os_exporter_usage_mon.service  
``[Unit]
Description=OpenStack Exporter usage monitor
After=network.target

[Service]
ExecStart=/usr/local/bin/os_exporter_usage_mon.sh
Type=simple

[Install]
WantedBy=multi-user.target``

vim /etc/systemd/system/os_exporter_usage_mon.timer  
``[Timer]
OnUnitActiveSec=15m
Unit=os_exporter_usage_mon.service``  

vim /usr/local/bin/os_exporter_usage_mon.sh  
``#!/bin/bash
set -x
LOG=/var/log/os_exporter_usage_mon.log
echo "----------------------------------------------------------" >> $LOG
echo "Current date: $(date +%d.%m)  $(date +%H:%M:%S)" >> $LOG
echo "USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME" >> $LOG
echo "$(ps axuf | grep openstack_expo | grep -v grep | cut -d'/' -f1)" >> $LOG``  

Change mod  
``chmod +x /usr/local/bin/os_exporter_usage_mon.sh``  

And restart everything  
``systemctl daemon-reload
systemctl restart os_exporter_usage_mon.timer
systemctl restart os_exporter_usage_mon.service  
systemctl enable os_exporter_usage_mon.service``  
### Check  
``cat /var/log/os_exporter_usage_mon.log``  
