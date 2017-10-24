---
layout: post
title: Configuration of ntp in secure environments
tags: linux ntp apparmor
---
### What to do when time of yours machines doesn't syncing  

Step 1. Find out correct ntp server address in your net.  
If you trying to configure time on machines in production environments there is a good chance tha default ntp server would not be accessible.  
_How to check ntp server accessibility_  
``service ntp stop  
ntpdate -su $ip  
tail /var/log/syslog``  

Step 2. Check your apparmor status - loaded profiles etc  
``apparmor_status``  
or
``aa-status``  
or  
``cat /sys/kernel/security/apparmor/profiles``  

Sample output  
``apparmor module is loaded.  
6 profiles are loaded.  
6 profiles are in enforce mode.  
   /sbin/dhclient  
   /usr/lib/NetworkManager/nm-dhcp-client.action  
   /usr/lib/connman/scripts/dhclient-script  
   /usr/sbin/mysqld  
   /usr/sbin/ntpd  
   /usr/sbin/tcpdump``
If you have similar output, you can also check dmesg output  
``dmesg``  
There you can find lines like  
`` audit: type=1400 audit(1508845970.970:16): apparmor="DENIED" operation="capable" profile="/usr/sbin/ntpd" pid=2606 comm="ntpd" capability=12  capname="net_admin"``  
It means that apparmor has blocked your ntp syncing and you should disable ntp profile     
Step 3. Disable ntp profile in apparmor  
``ln -s /etc/apparmor.d/usr.sbin.ntpd /etc/apparmor.d/disable/  
apparmor_parser -R /etc/apparmor.d/usr.sbin.ntpd``  
Step 4. Check that everything ok  
``service ntp stop  
ntpdate -su $ip  
tail /var/log/syslog  
dmesg``  
Step 5. Start service  
``service ntp start``  
