---
layout: post
title: Net basics  
tags: net cisco  
---

### Basic CISCO commands and tips from Netskills youtube course Young Fighter's Course  


#### Basics  
``enable      #enable privileged   
conf t        #configure global   
?             #help  
sh run        #show running configuration    
sh vlan       #show vlan configuration  
sh mac address-table   #show all macs from switch db    
do sh         #show something from conf t mode    
write mem     #save conf``  

#### Authorization and User management  
Enable login via password in console  
``enable   
conf t  
enable password new_pass  
``  
Encrypted password  
``enable    
conf t   
service password-encryption``  

Secret (More prioritized than password)  
``enable  
conf t  
enable secret new_secret``  

Create user  
``enable  
conf t  
username NEW_USER  privilege <0-15> NEW_PASSWORD``  

Enable local authorization  
``enable  
conf t  
line  console  0  
login  local``  


#### Interface configuraion / VLAN's  
Configure IP on switch port for telnet access  
``enable  
conf t  
interface Vlan1  
ip address 192.168.1.1 255.255.255.0  
no shutdown  
exit  
line vty 0 4  
transport input telnet  
login local  
end  
write mem``  


#### Vlan   
VLAN - ensure security in our infrastructure and give us an ability to make 4095 identical subnets with different VLAN's tags without any broadcast noise.  
Working on the second level of the OSI model.  
Two different port modes on switch's:
- Access ports (for end-users like computers)  
- Trunk ports (for other switches)  
Configuration:  
``enable  
conf t  
interface vlan 2  
name group_1  
exit  
interface  FastEthernet 0/1  
switchport mode access  
switchport  access vlan 2  
exit
interface GigabyteEhternet 0/1  
switchport mode  trunk  
switchport trunk allowed  vlan 2  
switchport trunk allowed vlan add 3  
exit  
``  

### STP  
STP - spanning tree protocol. Protects us from loops in our network and reduces broadcast traffic.  
How it works  
0. Connected switches begin to initialize connected ports (every 2 sec BPDU frames are send)
1. Switch with highest throughput elected as root swith in topology  
2. If all switches are identical in throughput then the switch with an lowest MAC address would be elected as a root   
3. On the next step root ports on non-root switches will be determined (same algorithm - lowest mac on highest throughput)  
4. Determination of the designate port on non-root switch (this port will be used for connection with blocked port from next step)  
5. Block of the port on another non-root switch  
So with topology which consists from three switches we have this picture:  
First Switch with the lowest MAC will be elected as a root switch with two ports in forwarding mode
Second switch with average MAC will be used as non-root switch with both ports in forwarding mode (one of them will be root port connected with root switch and aonther will be a designated port connected with a blocked port on the third switch)  
The last one switch with highest MAC ( or lowest throughput) will be determined as a non-root switch with one root port connected with root switch and another one blocked  

Commands:  
``spanning-tree  
spanning-tree vlan X priority    
spanning-tree vlan X primary   
spanning-tree vlan mode rapid-pvst``  
