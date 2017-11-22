---
layout: page
title: cheats
permalink: /cheats/
---

## Use ctrl + f

## Basis
### To avoid interface name changes via udev (pass options to kernel):  
net.ifnames=1 biosdevname=1

### Specify ssh options (password authentication)  
``ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no``  

### Java workarounds (jre8)  
1. start 'configure java' app
2. security - high level - edit security list - insert website url  
3. If you get 'unable to launch app' err message - click details  
in case of MD5RSA algorithm rejection edit with notepad file  
``/c/program files/java/jre8.../lib/security/java.security``  
and remove this algorithm from all 'disable' lines  

### Echo pipeline over SSH  
`` echo 'string' | ssh ubuntu@10.1.3.3 "cat >> /target/file"``  

### Get only response code from server  
curl -s -o /dev/null -I -w "%{http_code}"  http://ip:port  

### Check internet speed in cli (via speedtest.com by ookla)  
``curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -``  

### Check json from page (chrome)    
F12 -> Network -> Preserver log  

### Using rsync with append  
``rsync --append-verify SOURCE DEST``    

### Iptables basics  
flush rules  
``service iptables-persistent flush``  
print chains with line-numbers  
``iptables -nvL --line-numbers``  
delete rule by number and chain  
``iptables -D INPUT 3``  

### NodeJS webserver
``apt-get install -y nodejs npm nodejs-legacy  
npm install -g http-server  
http-server -p 81``  

### ASCII with CRLF terminators, removing CRLF  
``vim filename  
:set fileformat=unix  
:wq``  

### MYSQL consistent backup & restore  
``mysqldump --all-databases --single-transaction > all_databases.sql  
mysql -p < all_databases.sql``  

### Fuel plugins - Add version: 2.0.0 in deployment_tasks via VIM  
``'%s/^\s&ast;role: .&ast;/  version: 2.0.0\r&/g'``  

### Check missed packages on interfaces  
 ``ip -s -s link show``  

### Debug resource start via pcs  
``pcs resource debug-start``  

### check buffers:  
``ethtool -g``  

### set up maximum buffer for Nic  
``ethtool -G  rx``    
add this change to script - (RHEL)  
vim   /etc/sysconfig/network-scripts/ifcfg-NIC  
``ETHTOOL_OPTS="-G  rx <buffer size>"``    
#### !!!Changes to Tx buffer are not recommended because of devices on other side of link  

### Check crm disk status  (full disk)  
``crm node status-attr  show "#health_disk"      
delete flag``    

### Recursive sed replacement in files  
``find . -type f -exec sed -i 's/foo/bar/g' {} +``  

### Recursive Disk Usage  
``du -h --max-depth=1 /var/log | sort -hr``  
### WIFI connection password  
vim /etc/NetworkManager/system-connections/conn_name.conf  
``[wifi security]  
psk =``  

### Creating patches  
``diff -Naur oldfile newfile >new-patch``  

### Disabling cloud-init datasource search  
``echo 'datasource_list: [ None ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg``  
### Disabling service via update-rc.d  
``update-rc.d drbd disable``  

### Enabling corosync autostart  
vim /etc/default/corosync  
``change NO on YES``  

### Git insecure certificates  
``git config http.sslVerify false``
or  
``git -c http.sslVerify=false clone https://example.com/path/to/git``    

### Using deprecated branches  
``git checkout kilo-eol``  

### Enable password cache in git store  
``git config credential.helper cache``  

### Submitting existing repository in new gerrit repo  
``git clone $repo-from-stash  
cd $repo  
git checkout $branches #creating branches  
git remote add gerrit $gerrit-repo  
for i in {1000..1}; do echo $i; git reset --hard HEAD~$i; if [[ $? == 0 ]]; then break; fi;  done #searching for first commit for squashing  
git merge --squash HEAD@{1}    #squashing  
git commit  
git pull gerrit $branch     #fetching repo to common ancestor  
git-review #Voila!``  
repeat all steps for all branches   

### Sed all files in dir  
``find . -type f -print0 | xargs -0 sed -i 's/str1/str2/g'``  

### FC scsi bus rescan  
``echo 1 > /sys/class/fc_host/host#/issue_lip``  
or apt install sg3_utils SCSI bus rescan  
``echo “- - -” > /sys/class/scsi_host/hostH/scan``  
or (working on fuel/vsphere)  
``ls /sys/class/scsi_device/  
2:0:0:0  3:0:0:0  
echo 1 > /sys/class/scsi_device/2\:0\:0\:0/device/rescan    
echo 1 > /sys/class/scsi_device/3\:0\:0\:0/device/rescan``  

### Drop vm cache  
``echo 3 > /proc/sys/vm/drop_caches``  

### Identify wwn of fc card  
``cat /sys/class/fc_host/hostX/device/fc_host/hostX/node_name``  

### Find deb package by filename  
``dpkg -S file.name``  

### Find rpm package by filename  
``rpm -qi --filesbypkg $package``  

### QCOW2 to VMDK openstack convertation  
``qemu-img create -O vmdk -o adapter_type=lsilogic,compat6 ubuntu.qcow2 ubuntu.vmdk``  

### How to avoid drbd "start mounting" / "start daemon" race condition  
vim /etc/network/if-up.d/drbd-start  
``#! /bin/sh  
/etc/init.d/drbd start``  
vim /etc/fstab  
``/dev/drbd1 /home ext3 _netdev,relatime 0 2``  

### Openstack keepalived vip in instances  
1. create new neutron port  
2. install keepalived, configure (Search by tag keepalived on this site)  
3. ``neutron port-update  $VIP_portid --allowed-address-pairs type=dict list=true   ip_address=VIP,mac_address=mac1 ip_address=VIP,mac_address=mac2``    
4. ``neutrom port-update $vm1_porti --allowed-address-pairs type=dict list=true   ip_address=$ip1,mac_address=vm1_mac ip_address=$vip,mac_address=vm1_mac``    
    same thing with vm2  
4. start keepalived, check connectivity  

### Install simple VM via virsh  
``qemu-img create -f qcow2 /var/lib/libvirt/images/cloud-linux.img 15G   
virt-install --connect qemu:///system --hvm --name cloud-linux --ram 1548 --vcpus 1 --cdrom path_to_iso --disk path=/var/lib/libvirt/images/cloud-linux.img,format=qcow2,bus=virtio,cache=none --network network=default,model=virtio --memballoon model=virtio --vnc --os-type=linux --accelerate --noapic --keymap=en-us --video=cirrus --force``  

### Ceph debugging
``ceph -s ( Check your active flags (like norecovery, nobackflip, etc...))  
ceph osd tree  
ceph health detail (| grep blocked)  
telnet monitor : 6789 (on ctrl node)  
status ceph-osd id=$id  
ceph pg dump | grep stuck``    

### Windows7 doesnt use hosts file  
_Solution by Wol_[Beware if spacing in windows 7 hosts file](http://geekswithblogs.net/JanS/archive/2009/06/17/beware-of-spacing-in-windows7-hosts-file.aspx)  
1. cd \Windows\System32\drivers\etc ###go to the directory where the hosts file lives  
2. attrib -R hosts ###just in case it's Read Only, unlock it  
3. notepad hosts ###now you have a copy of hosts in Notepad  
4. del hosts ###yep. Delete hosts. Why this is necessary -- why ANY of this should be necessary -- I have no clue  
5. Now go into Notepad and Ctrl-S to put the hosts file back. Note: Ctrl-S should save it as "hosts" without any extension. You want this. Be sure not to let Notepad save it as "hosts.txt"  
6. ipconfig /flushdns --possibly unnecessary, but I did it this way and it worked  
7. attrib +R hosts --make hosts file Read Only, which adds as much security as you think it does  

## Postgresql Pgpool  
Check recovery nodes  
``sudo -u postgres psql -h 172.21.3.41 -p 5432 -x -c "show pool_nodes;"  
sudo -u postgres psql -h 172.21.3.229 -p 5432 -x -c "select pg_is_in_recovery();"``  

### Testing LB  
``sudo -u postgres pgbench -i  
sudo -u postgres pgbench -p 5432 -h pgpool_vip -c 10 -S -T 10 postgres  
sudo -u postgres psql -p 5432 -h pgpool_vip -c "show pool_nodes" postgres``  

### PCP commands  
``pcp_node_count -h /var/run/postgresql -p 9898  
pcp_attach_node -h /var/run/postgresql -p 9898 0 (return node after reboot)``  

### Mcollective  
Some mcollective useful commands  
``mco rpc -v excurte_shell_command execute cmd="shotgun2 short-report" -I master``  

##Cisco  
### Monitoring in console  
``term mon``  

### Check link   
_on server_  
``ifconfig interface up``    
_on switch_  
``show status int eth1/1``   

### Check interface status: show interface status  
``Grep: | include ....``    
_Check config_  
``show run conf | inc``  

## Cisco LACP  
_cdp vpc_  
1. enable cdp  
2. enable vpc  
3. create vpc domain  
4. configure keepalive dest mgmt-ip-peer source mgmt-ip    
5. create portchannel group LACP mode active  
6. feature lacp  
TRUNK  
7. configure if-range  
8. spanning tree  
9. assign if-range to portchannel  
_Example_  
``eth1809-3: conf t  
eth1809-3(config): interface port-channel 1  
eth1809-3(config): negotiate auto  
eth1809-3(config): vpc 1  
eth1809-3(config): switchport mode trunk  
eth1809-3(config): exit  
eth1809-3(config): interface eth1/1  
eth1809-3(config): no sh  
eth1809-3(config): switchport mode trunk  
eth1809-3(config): channel-group 1 mode active  
eth1809-3(config): exit  
eth1809-3(config): wr``  

### Enable Jumbo frames  
``cz-eth1809-3(config)# policy-map type network-qos jumbo  
cz-eth1809-3(config-pmap-nq)#   class type network-qos class-default  
cz-eth1809-3(config-pmap-nq-c)#           mtu 9216  
cz-eth1809-3(config-pmap-nq-c)# system qos  
cz-eth1809-3(config-sys-qos)#   service-policy type network-qos jumbo``  

## Vmware/vsphere  
### Port security configure  
1. Hosts  
2. Host  
3. Configure  
4. Networking  
5. vswitch edit  
6. Disable all security checkbox  

### Disconnected /deactivated datastore  
#### Check your license first  

### Influxdb openstack access  
1. find astute.yaml, and values  influxdb_dbname, influxdb_username, influxdb_userpass and in vips section -  vips>influxdb>ipaddr
2. access database
``influx -host IPADDR -username INFLUXDB_USERNAME -password INFLUXDB_USERPASS -database INFLUXDB_DBNAME  
SHOW MEASUREMENTS  
SHOW FIELD KEYS FROM virt_memory_total``  

### Influx cache maximum memory size exceeded #6109  
_Sample from logs_  
``14:52:07 reading file /data1/influxdb/wal/sysnoc/default/2/\_00703.wal, size 10504926 [cacheloader] 2016/03/24 14:52:09 reading file   /data1/influxdb/wal/sysnoc/default/2/\_00704.wal, size 10494123 run: open server: open tsdb store: [shard 2] cache maximum memory size exceeded``  

Solution  
vim tsdb/engine/tsm1/cache.go  
``   @@ -306,6 +306,12 @@ func (c &ast;Cache) Delete(keys []string) {
       }  
   }  

+func (c &ast;Cache) SetMaxSize(size uint64) {  
+    c.mu.Lock()  
+    c.maxSize = size  
+    c.mu.Unlock()  
+}  
+``  
vim tsdb/engine/tsm1/engine.go  
``@@ -659,6 +659,14 @@ func (e &ast;Engine) reloadCache() error {  
         return err  
     }  

+    limit := e.Cache.MaxSize()  
+    defer func() {  
+        e.Cache.SetMaxSize(limit)  
+    }()   
+  
+    // Disable the max size during loading  
+    e.Cache.SetMaxSize(0)  
+  
     loader := NewCacheLoader(files)``  
restart influxdb  
``service influxdb restart``  

## Haproxy  
### If haproxy cannot start on all nodes after deployment ('cannot bind soc' after /usr/lib/ocf/resource.d/fuel/ns_haproxy reload), check this nonlocal_bind bug  
[bug](https://bugs.launchpad.net/fuel/+bug/1659205)

Solution  
``ip netns delete haproxy  
/usr/lib/ocf/resource.d/fuel/ns_haproxy start  
crm resource cleanup clone_p_haproxy``  

### Haproxy ssl  
Enabling tls on grafana  
``scp kibana.lma.mos.cloud.sbrf.ru.chain.pem kaira6:/var/lib/astute/haproxy/``  
vim /var/lib/astute/haproxy/kibana  
``bind 10.127.32.37:80  
bind 10.127.32.37:443 ssl crt /var/lib/astute/haproxy/kibana.lma.mos.cloud.sbrf.ru.chain.pem no-sslv3 no-tls-tickets ciphers AES128+EECDH:AES128+EDH:AES256+EECDH:AES256+EDH  
balance source  
option forwardfor  
option httplog  
reqadd X-Forwarded-Proto:\ https  
stick on src  
stick-table type ip size 200k expire 30m  
timeout client 3h  
timeout server 3h``  

Grafana  
``bind 10.127.32.37:80  
bind 10.127.32.37:443 ssl crt   /var/lib/astute/haproxy/grafana.lma.mos.cloud.sbrf.ru.chain.pem no-sslv3 no-tls-tickets ciphers AES128+EECDH:AES128+EDH:AES256+EECDH:AES256+EDH  
balance source  
option httplog  
option httpchk GET /login/ HTTP/1.0  
reqadd X-Forwarded-Proto:\ https  
stick on src  
stick-table type ip size 200k expire 30m``  
DELETE this line  
``option forwardfor``  

## Swift  
### Swift with Ceph - troubleshooting  
Kraken release, error: NO_SUCH_BUCKET/ACCOUNT/404  
1. Verify your endpoints, (they should contain :8080/swift/v1/%(tenant_id)s postfix)   
2. Check your ceph.conf    
``[client.radosgw.gateway]  
rgw keystone api version = v2.0  
rgw keystone url = http://192.168.0.2:35357  
rgw_keystone_admin_token = P.......iu.f..  
rgw swift account in url = true  
rgw keystone implicit tenants = false``  
3. restart all radosgw services on all radosgw nodes  
``service radosgw-all restart``  

## GOlang  
1. Clone repo - go get github/user/repo (alternatively, you can manually clone repo in gopath:/src/ dir )  
2. In case of problems with goroot/gopath - unset GOROOT variable  
3. In case of problems with http.requests&ast; (or context) calls - update GOlang to >1.8.3  
4. Find all dependencies for package:  
     ``go list -f '{{join .Deps "\n"}}''``  
5. 'import cycle not allowed' - unset all GO variables, and run  
``go get github/user/repo``  


## SSL  
Generate right self-signed certs  
``openssl req -x509 -newkey rsa:4096 -keyout kibana-lol.it.com.pem -out  kibana-lol.it.com.cert -days 365 -nodes  
echo  kibana-lol.it.com.cert >> kibana-lol.it.bundle  
echo  kibana-lol.it.com.pem  >> kibana-lol.it.bundle``  

### Jenkins ssl (Docker)  
``docker exec -it -u root `docker ps | grep jenkins|awk '{print $1}'` bash  
openssl pkcs12 -export -in .crt -inkey .key -out jenkins.p12  
keytool -importkeystore -srckeystore jenkins.p12 -srcstoretype PKCS12 -destkeystore jenkins_keystore.jks -deststoretype JKS  
keytool -list -v -keystore jenkins_keystore.jks | egrep "Alias|Valid"  
docker run -v /home/ubuntu/johndoe/jenkins:/var/jenkins_home -p 443:8443 jenkins --httpPort=-1 --httpsPort=8443 --httpsKeyStore=/var/jenkins_home/jenkins_keystore.jks --httpsKeyStorePassword=``  

### Ssl root ca cert add  
``mv cacert.crt /etc/ssl/certs/``  

### Check a certificate  
``openssl x509 -in certificate.crt -text -noout``  
or  
``openssl x509 -noout - hash - in cacert.crt``  

### Openstack ca-bundle right order (hosttelecon)  
1. crt      
``Issuer: C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA Domain   Validation Secure Server CA  
Subject: OU=Domain Control Validated, OU=EssentialSSL Wildcard, CN=&ast;.atlex.cloud``  
2. Bundle  
2.1
``Issuer: C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA   Certification Authority  
Subject: C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA Domain   Validation Secure Server CA``  
2.2  
``Issuer: C=SE, O=AddTrust AB, OU=AddTrust External TTP Network, CN=AddTrust External CA Root  
Subject: C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA   Certification Authority``  
3. RSA Key  

### SSL Sparc Oracle  
Verify  
``openssl x509 -noout -text -in Elbonia_Root_CA.pem``    
Chmod  
``chmod a+r Elbonia_Root_CA.pem      
cp -p Elbonia_Root_CA.pem /etc/certs/CA/``  
Insert the cert in the end of file _/etc/certs/ca-certificates.crt_  
Hash  
``c_rehash .``  
link  
``/usr/sbin/svcadm restart /system/ca-certificates``  
``update-ca-certificates``  

### Fuel postdeploy ca add  
``1. Add cert in UI  
2. fuel node --node $i --tasks upload_configuration  
3. fuel node --node $id --tasks $ssl_tasks $haproxy-service-tasks $keystone-service-tasks  
4. Profit``  

### why curl is working but clients are not  
Python-requests looks into /etc/ssl/certs/ , but right after installation _certify_ looks into  
``/usr/lib/python2.7/dist-objecti/certifi/bundle``  
This bundle doesn't include self-signed certificates so it maybe the case why clients couldn't work with your certificates.  
Another thought. You  can append your certificate to ca_certificates.crt and run  
``update-ca-certificates``  
As last resort u can check your chain one more time - maybe you have there bundle's open part while it should not be there.  

## LDAP  

### ldap 2 less  
``ldapsearch -x -LLL -h ****.ru -p 3268 -D openstack_ldap_user@*****.ru -w 'D*****2%$******X5(' -b DC=ti,DC=local -s sub "(sAMAccountName=a.sh******)" -P 3 -e ! chaining=referralsRequired``  
``ldapsearch -x -LLL -h 127.0.0.1 -p 389 -D cn=administrator,dc=local,dc=ru -w BNkmv/OEt+z1su_g_A_p_q_PjO6uA1C1 -b dc=***********,dc=ru -s sub "(sAMAccountName=a.*****ev)"``  

## Python using ssl verify cert  
``import requests  
url = 'https://foo.com/bar'  
r = requests.post(url, verify='/path/to/ca')``    

## Zabbix  
### mariadb-mysql  

1. Persistent change of allowed connections   
``vi /etc/my.cnf.d/server.cnf``  
2. Permanent change
``mysql -u root -p; show variables like 'max_connections'
set global max_connections = 1000;``
3. Check _/usr/lib/systemd/system/mariadb.service_  
sudo vi /etc/systemd/system/mariadb.service  
``.include /lib/systemd/system/mariadb.service  
[Service]  
LimitNOFILE=10000  
LimitMEMLOCK=infinity``  
3. Agent timeouts  
vi /etc/zabbix/zabbix-server.conf   
``Timeout 30;``  
4. Poller busy  
vi /etc/zabbix/zabbix-server.conf  
``StartPollers=200;``  
5. Manual integration  
``install agents (wget)  
place scripts in /etc/zabbix/scripts   
Fill _server serveractive userparameters_ options in /etc/zabbix/zabbix-agent.conf  
Log in webui, setup autodiscovery of agents  
Import templates  
Link them on group of nodes``  
Full [post]({{ "/_posts/2017-10-12-zabbix.md" }})  

## Fuel master, docker  
### issues  
jenkins/jenkins image    
1. no running docker daemon/  
solution  
``apt install docker-engine (1.12. if using rancher)``
2. error "cannot connect to docker daemon" during jenkins pipelines/  
solution  
``chmod 777 /var/run/docker.sock in jenkins container``  

## Rancher  
### bugs  
1. if you are experiencing some net-shit (like no bridge-net failures, empty json response and so)
mb your rancher-agent which runs on rancher-server host has got a wrong ip (docker ip 172...)
Solution  
go to rancher-server node, run on host command 'export CATTLE_AGENT_IP=$ip' and then readd host'
2. If you delete kubernetes stack in rancher and recreate it and your new stack constantly fails, when you should manually remove volumes from vms on which k8s stack based (/var/lib/docker ....).  Main reason for this is that we need purge old config data form etcd volumes.    
## Docker  
### Push limage to remote registry  
``docker login nexus.example.com:18444  
docker build .  
docker tag af340544ed62 nexus.example.com:18444/hello-world:mytag   
docker push nexus.example.com:18444/hello-world:mytag``    
If nothing happens  
vim /etc/docker/daemon.json  
``{ "insecure-registries":["myregistry.example.com:5000"] }   
/etc/init.d/docker restart``  

### basic docker cmd  
``1. dockerctl list  
2. dockerctl check   
3. dockerctl restart <contain.name>  
4. dockerctl backup / restore``  

### Delete all containers  
``docker rm $(docker ps -a -q)``    

### Delete all images  
``docker rmi $(docker images -q)``  

## Fuel  
### Change fuelmenu settings  
``./bootstrap_admin_node.sh``  

### Kernel update to 4.4 for Fuel 9.0   
``cp fuel_bootstrap_cli.yaml fuel_bootstrap_cli.yaml.bak  
sed -i -e 's/generic-lts-trusty/generic-lts-xenial/g' \
  -e '/-[[:blank:]]&ast;hpsa-dkms$/d' fuel_bootstrap_cli.yaml  
fuel-bootstrap build --activate --label bootstrap-kernel44``  

### Fixing fake disks issue on discover nodes  
(unsquah /squah active bootstrap, and add new line with Container)  
https://git.openstack.org/cgit/openstack/fuel-nailgun-agent/commit/?id=13fb4009d3f7c46222791bb9623cb05f8ba42ad8  
``mdraid mdadm``  

### Plugin sync and graph  
vim /var/www/nailgun/plugins/plugin_name/...  
``fuel plugins --sync  
fuel graph --env env_id | grep task``  

### Fuel disable/enable plugins for removing from env  
``fuel --env 1 settings -d  
fuel --env 1 settings -u -f``  

### Fuel rsync library  
``fuel node --node 1 --start rsync_core_puppet --end plugins_rsync``  

### Puppet dir for plugins on master-node (7)  
``/var/www/nailgun/plugins``  

### Removing plugin with 'syntax error near fi' error  
``rpm -e --noscripts $package_name  
If there no active connection to nailgun in gui (7.0)  
and docker cannot check status of containers due to empty pass creds, do:  
1. cp /etc/fuel/astute.yaml.old /etc/fuel/astute.yaml  
2. dockerctl check all``  

### Controller+compute fix  
``fuel role --rel 2  --role controller  --file 1.yaml``  
vi 1.yaml  
``Conflicts: []``  

``fuel role --rel 2  --update --file 1.yaml``  
In UI network settigns -> l3 -> enable DVR  

### Change hostnames for all nodes  
``fuel node | grep -E "^(\ )&ast;[0-9]" | awk '{print $1,$5}' | while read id hostname; do   fuel node --node-id $id --hostname $hostname; done``  

### Fuel-graph  
``fuel graph --download file.dot``    
open this .dot in OmniGraffle Or GraphViz  

### Bugs  
0. Mcollective fail (last_run execution puppetd, yaml)
fix - delete
``/var/lib/puppet/state/last_run_summary.yaml  
/var/lib/puppet/state/last_run_report.yaml``  

1. 8th Fuel often cannot config rabbits container at start, and dont waiting for him
restart puppet apply in rabbitmq container  
``rabbit apply .... nailgun/examples/rabbitmq_only.pp``  
2. You MUST setup correct pxe settings  DURING deployment process of master node. To do so, you need to choose standart installation and after post-installation scripts and reboot press SPACEBAR when you will be prompted to 'press a key'  
3. If you want advanced installation you MUST specify your primary mac adress in bootloader option (press TAB while selecting advanced option and change XX:XX:XX:XX:XX on your mac)  
4. PXEe/admin network MUST have native vlan or nodes will not bootstraped through ubuntu_bootstrap image (cobbler:/var/lib/tftpboot/images/ubuntu_bootstrap)  
5. NO dots '.' in hostnames of controllers - or rabbitmq will fail (NX domain error)  
6. NO small partitions ( ~64 mb) in fuel node config  
7. After every reset of environment disks configuration also resets  
8. After 3 attemps of deploing task (puppet) task will fail, but deploying process will go further  
9. Dont use Qemu hypervisor - use KVM instead  
10. If you using local repo, u must run `fuel-mirror apply -G mos -P ubuntu` - or cloud-init module mcollective will not start and provisiong will fail  
11.  Another possible error after 100% provisiong and node reboot -
if you are using boot-volume it have 2 disks, at least. one small (64mb)
 and one primary. If your provisioning fails maybe its because cloud-init
cannot find it data_source on primary disk(beacuse its on small one).
In this case, use this workaround on nodes on discover phase:
dd if=/dev/zero of=/dev/vdb bs=1M count=64  
12. If you have more than one nodegroup you should check accordance between nodegroups and group_id of nodes or your deployment will like failed with non-understandable error in nailgun like '24' '22' 'gateway' and so.  

## Elasticsearch and LMA  

## Influx  
### access and query  
``grep timestamp /var/log/influx.log  
log in influx  
use lma;  
Select .... from ... as as;``  

## Elasticsearch  
### check cluster status  
``curl localhost:9200/_cluster/health``  

### figure out which indices are in trouble  
``curl 'localhost:9200/\_cluster/health?level=indices&pretty'``  

### figure out what shard is the problem  
``curl localhost:9200/\_cat/shards``  

### query to all objects  
``curl elastic_vip:9200/_all/compute.instance.exists/_search?
pretty=true&size=10000``  

### query to specific object (events_2017-06-26)  
``curl -XGET '$ES_URL/events_2017-06-26/snapshot.create/_search?pretty'``  

### query indices  
``curl 'localhost:9200/_cat/indices?v'``  

### query mappings  
``curl -XGET '$ES_URL/events_2017-06-26/\_mapping?pretty'``  

### lma_diagnostic  
`` sh lma_diagnostics``  

### check buffer    
``heka-cat -offset=48175879 /var/cache/log_collector/output_queue/elasticsearch_output/0.log | head -n 30``  

### to recover ES index, you can try  
``curl http://ES:9200/log-2016-11-15/_flush?force  
then run  
curl -XPOST 'http://ES:9200/_cluster/reroute'``  

### checking logs  
``ls -l /var/cache/log_collector/output_queue/elasticsearch_output/  
cat /var/cache/log_collector/output_queue/elasticsearch_output/checkpoint.txt - check if its value is changing   
tail -n 30 /var/log/log_collector.log``  

### about idle packets messages  
this kind of messages (idle pack) are not critical as long as they are changing over the time (numbers of pack per plugin) this could mean that messages are "waiting" for some time to let processing other messages (backpressure in heka terminology)  

### increasing poolsize  can help in case of idle packets  
vim /etc/log_collector/global.toml  
``increase poolsize to 200  
crm resource restart p_clone-log_collector``  

## Rally  
### One-node-deployment ib venv  
``wget -q -O- [https://raw.githubusercontent.com/openstack/rally/master/install_rally.sh](https://raw.githubusercontent.com/openstack/rally/master/install_rally.sh)  
chmod +x install_rally.sh  
./install_rally.sh -d venv``   
vi venv/samples/deployments/existing.json  
``rally deployment create --filename venv/samples/deployments/existing.json --name luxof``

### If you have multi region environment  
1) change two lines (search "region") here on hard-coded name of  your region  ``lib/python2.7/site-packages/rally/osclients.py#L196``   (and if you installed rally in venv in /venv/lib/python.....)
2) Also change line in neutron return in osclients.py  
``L357 client = neutron.Client(self..........   endpoint_override=self.\_get_endpoint(service_type))``  

### In case of multiple networks  
for every failed task do this  
vim /venv/src/sample/tasks/scenarios/nova/boot-and-delete.yaml  
``args:  
        flavor:....  
        image:.....  
        nics: [{"net-id": "id"}]``  

### Customize certification tests  
vi venv/src/certification/openstack/task_arguments.yaml  

``service_list:  
- authentication  
- nova  
- neutron  
- keystone  
- cinder  
- glance  
use_existing_users: false  
image_name: "^(cirros.&ast;uec|TestVM)$"  
flavor_name: "m1.tiny"  
glance_image_location: "/root/cirros-0.3.4-i386-disk.img" (Image must be there, you know)  
smoke: false  
users_amount: 30 (for test run you can use 1)  
tenants_amount: 10  
controllers_amount: 3  
compute_amount: 3  
storage_amount: 4  
network_amount: 3``  

vi venv/lib/python2.7/site-packages/rally/plugins/openstack/scenarios/nova/utils.py  
``line 112: def \_boot_server(self, image_id, flavor_id,  
auto_assign_nic=True, **kwargs)``  

vi src/certification/openstack/scenario/cinder.yaml  
``line 162: CinderVolumes.create_nested_snapshots_and_attach_volume
args:  
nested_level: 5``  

### Rally Start  

``rally task start rally.git/rally/certification/openstack/task.yaml --task-args-file rally.git/rally/certification/openstack/task_arguments.yaml``  

## Ceph Osd Rbd  

### Allow compute nodes to write in pool  
``ceph auth caps client.compute osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=images, allow rwx pool=compute' mon 'allow r'``  

### ceph noin  
``ceph osd set noin``  

### ceph log per osd  
``ceph daemon osd.0 log dump``  
ceph log per osd grep slowest recent ops
``ceph daemon osd.0 dump_historic_ops``  
utlilization of ceph  
``ceph osd reweight-by-utilization 115``  
normal utilization is 120% average_util*120 = % drive full osd

### Ceph fio instance testing  
 ``fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --runtime=120 --readwrite=randrw --rwmixread=75 --size=15G``  

### Image upload to ceph rbd  
``rbd --pool images ls -l rados put {object-name} {file-path} --pool=data rbd -p images –image-format 2 import cirros-0.3.0-x86-64-disk.img.1 $(uuidgen) rados lspools>``  

### ISCSI mapping из rbd (for vmware and others) through tgt  
 ``apt-get install tgt  
 tgtadm --lld iscsi --mode system --op show (‘rbd’ should appear in “Backing stores:” if your tgtd supports rbd.) rbd create iscsi-image --size 50000 tgtadm --lld iscsi --mode target --op new --tid 1 --targetname rbd tgtadm --lld iscsi --mode logicalunit --op new --tid 1 --lun 1 --backing-store iscsi-image --bstype rbd tgtadm --lld iscsi --op bind --mode target --tid 1 -I ALL``  

### ISCSI connect to node  
``iscsiadm -m discovery -t st -p $IP iscsiadm -m node --login iscsiadm -m node -u``  

### Hyper-v Openstack integration win 2012 r2  
On nova-compute

1. Install on windows node https://cloudbase.it/installing-openstack-nova-compute-on-hyper-v/  
2. Configs  
c:/program files(x86)/Cloudbase/Openstack/Nova/etc/nova.conf neutron.conf  
 ``[glance] api_servers=http://endpoint  
 [neutron] url=endpoint; admin_tenant = serviceS; enable_security_groups=true  
 [oslo_messaging] rabbit_host - br_ex ip``  
!! IMPORTANT: enable rabbit listening on 0.0.0.0 on controller node (vi /etc/rabbit/rabbit-env) - and restart it !!  
3. Upload vhd images to glance  
 ``qemu-img convert ubuntu12x64.min -O vpc -o subformat=dynamic ubuntu12x64.vhd
 glance image-create --container-format bare --disk-format vhd --name 'sample' --file 'ubuntu12x64.vhd'``  
4. Check hypervisors in Openstack (horizon - admin - hypervisors, disable all hypervisors, except hyper-v on windows - for testing)  
5. Check logs on windows machine - C:/Openstack/Logs/  
https://ashwaniashwin.wordpress.com/2014/06/27/configure-remote-desktop-connection-to-hyper-v-virtual-machine/
Neutron (vxlan)  
6. We need to create 2 interfaces on VM - first interf in br-ex net and vlan trunk as second.
Make NIC team (VLAN ID=private network id) from second adapter   https://blogs.technet.microsoft.com/keithmayer/2012/11/20/vlan-tricks-with-nics-teaming-hyper-v-in-windows-server-2012/  
Disable firewall. After that you must have connectivity on both interfaces (in br-mesh and br-ex nets)  
Install ovs agent for windows - https://cloudbase.it/open-vswitch-24-on-hyperv-part-1/  
Make ovs settings (br-tun) as on compute nodes  
Add "\_" to c:/program   files/cloudbase/openstack/nova/python2.7/site-packages/hyperv/neutron/hyperv_neutron_agent.py  
https://git.openstack.org/cgit/openstack/networking-hyperv/commit/?id=8bc5a0352379cddc57c618ff745cee301b403b66  

### If you want vlan connectivity between hyperv node and openstack you should use neutron-hyperv-agent  
Pass steps from 1 to 3 and your environment will be ready.  

### Openstack contrail - vm problems  
###$ Problem: No ssh connection to vm or bad net on compute node  
Solution  
``ethtool -K eth0 tx off  
ethtool -K eth1 tx off  
ethtool -K bond0 tx off  
ethtool -k bond0  
(after reboot it disappers, so you need install new cron-  
@reboot ethtool -K eth0 tx off )``  

## Hp snmp hardware monitoring  
``apt-get install snmp snmpd  
iptables -I INPUT 1 -p udp --dport 161 -m comment --comment "snmp port" -j ACCEPT  
iptables -I INPUT 1 -p tcp --dport 161 -m comment --comment "snmp port" -j ACCEPT  
vi /etc/snmp/snmpd.conf agentAddress udp:161  
view - commented  
vi /etc/apt/sources.list.d/hp.list deb   http://downloads.linux.hpe.com/SDR/downloads/MCP/ubuntu precise current/non-free  
apt-get update  
apt-get download libc6-i386=2.19-0ubuntu6.7  
dpkg -i libc6-i386_2.19-0ubuntu6.7_amd64.deb  
apt-get install hp-health  
wget http://downloads.linux.hpe.com/SDR/downloads/MCP/ubuntu/pool/non-free/hp-snmp-agents_10.0.0.1.23-20._amd64.deb  
dpkg -i hp-snmp-agents_10.0.0.1.23-20.\_amd64.deb  
/sbin/hpsnmpconfig  
service snmpd restart  
snmpwalk -v1 -c public localhost 1.3.6.1.4.1.232  
zabbix template - hp_snmp_agents``  

## Supermicro snmp hardware monitoring  
U'll need SuperDoctor 5 (x64) - http://www.supermicro.com/solutions/SMS_SD5.cfm  
Also, you will need java 1.8 (jdk, preferable - just download java from oracle site, unzip and write export PATH=PATH:/opt/java/ to bashrc)  
Scp superdoctor on all nodes  
Run SuperDoctorInstaller x64  
During installation, specify your jdk path - /opt/java/jdk1.8/bin/java; Set other promts to default  
apt-get install snmpd snmp;  
vi /etc/snmp/snmpd.conf pass .1.3.6.1.4.1.10876   /opt/Supermicro/SuperDoctor5/libs/native/snmpagent rwcommunity public 127.0.0.1 rocommunity readonly 127.0.0.1 rwcommunity public 10.216.203.241 trapsink localhost public  
Comment out all lines with 'view' 'access' and so.  
service snmpd restart && service sd5 restart.  
SD5 is very buggy tool, so you'll maybe need another restart/reboot.  
Check logs, check /opt/Supermicro/SuperDoctor5/libs/native/snmpagent -n .1.3.6.1.4.1.10876;  
For hard drives monitoring im using custom bash script with zabbix agent in front.  
Example  
### 10.1  
vi /etc/zabbix/scripts/check_drive.sh  
``!/bin/sh -f  
PATH=$path:/bin:/usr/bin:/usr/ucb REQ="$1"  
echo $REQ  
udisks --show-info /dev/sda | grep FAIL > /dev/null; sda=$?  
echo "sda -$sda sdb -$sdb sdc -$sdc sdd -$sdd" >> /tmp/log  
echo "$RET"  
case "$REQ" in sda) echo "$sda" ;; esac``  
### 10.2
vi /etc/zabbix/zabbix_agentd.conf  
``Drives  
UserParameter=drive.status.sda,/etc/zabbix/scripts/check_drive.sh sda 10.3 service zabbix_agent restart``  
### Zabbix haproxy default bug  
vi /etc/zabbix/scripts/haproxy.sh  
``"-v")  
OPER='value'  
IFS=$'.'  
QA=($2)  
unset IFS  
HAPX=${QA[0]}  
HASV=${QA[1]}  
ITEM=${QA[2]}``  

## Murano Bugs  
vim /usr/lib/python2.7/dist-packages/murano/api/v1/catalog.py  
``search def get_ui  
insert line tempf.flush()``  

## Mysql create base  
Grafana  
``create database grafana;  
create user 'grafana'@'%' identified by 'grafana';  
grant all privileges on grafana.&ast; to 'grafana'@'%';  
quit;``  
 
## Puppet notes  
### Default parameter values   
Use with capitalized resource spec wihout title   
``Exec { path => ['/usr/bin', '/bin'] }``  

### Native mysql commands  
``use module "puppetlabs-mysql"``  
### Variable in variable  
``for facter $mule = "ipaddress_${name}" $donkey = inline_template("<%= scope.lookupvar(mule) %>") notify { "Found interface $donkey":; }``  
### Chain in conditional  
``$cinder_volume_exist = inline_template("<% if File.exist?('/etc/init.d/cinder-volume')   -%>;true<% end -%>") cinder_config {  
                   .......  
}  
if $cinder_volume_exist == 'true' {  

  exec {"service cinder restart"  
           command =&gt; "service cinder-volume restart",  
  }  
Cinder_config &lt;||&gt; ~&gt; Exec['service cinder restart']  
}``  
### accessing arrays  
``$arr[0]``  
### hiera_hash  
``/etc/fuel/clsuter/id/astute.yaml``  
### Array var in resource declaration  
``define process_osd {  

exec { "Prepare OSD $name":  

      command =&gt; "ceph-deploy --ceph-conf /root/ceph.conf osd prepare   localhost:$name$arr_len"  
 }  
}  
process_osd { $dev : }``  

## NEUTRON provider network FUEL deployment  
### Get future deployment settings  
``fuel deployment --env $env_id –default``  
### Update template for each node (Put these sections to the end of template)  
vim deployment_3/&ast;.yaml transformations  
``action: add-br name: br-private-phys  
action: add-br name: br-private provider: ovs  
action: add-patch bridges:  
br-private  
br-private-phys provider: ovs mtu: 65000  
action: add-port name: bond0 bridge: br-private-phys``  

Upload templates  
``fuel deployment --env $env_id --upload``  

## Neutron tips  
### In case of network unreachable in cloud-init  
``crm resource restart p_clone_neutron_dhcp_agent``  
### In case of connection refused  
``service neutron-l3-agent restart``  

## NEUTRON Provider network  
### configuring provider network  
``controller  
brctl addbr br-aux0  
brctl addif br-aux0 eth1  
ovs-vsctl add-br br-prv  
ovs-vsctl add-port br-prv aux0-prv  
set Interface aux0-prv type=internal  
brctl addif br-aux0 aux0-prv  
ifconfig br-aux0 up  
ifconfig br-prv up  
ifconfig aux0-prv up``  

compute  
``brctl addbr br-aux0    
brctl addif br-aux0    
eth2 ovs-vsctl  
add-br br-prv  
ovs-vsctl add-port br-prv aux0-prv  
set Interface aux0-prv type=internal  
brctl addif br-aux0 aux0-prv  
ifconfig br-aux0 up  
ifconfig br-prv up  
ifconfig aux0-prv up  
nano /etc/network/interfaces.d/ifcfg-aux0-prv  
iface aux0-prv  
inet manual  
ovs_bridge br-prv  
ovs_type OVSIntPort  
nano /etc/network/interfaces.d/ifcfg-br-aux0  
auto br-aux0  
iface br-aux0  
inet manual  
bridge_ports eth2 aux0-prv  
nano /etc/network/interfaces.d/ifcfg-br-prv  
auto br-prv  
allow-ovs br-prv  
iface br-prv  
inet manual  
ovs_ports aux0-prv  
ovs_type OVSBridge dfs  
nano -c /etc/neutron/plugin.ini  
… [ml2_type_vlan] … network_vlan_ranges = physnet1:33:63 [ovs] ... bridge_mappings =   physnet1:br-prv ...``  

controller
``service neutron-server restart  
crm resource restart p_neutron-plugin-openvswitch-agent  
crm resource restart p_neutron-l3-agent``  

compute  
``service neutron-plugin-openvswitch-agent restart  
service nova-compute restart``  

VERIFY  
``neutron net-create --provider:network_type=vlan \
--provider:physical_network=physnet1 --provider:segmentation_id 33 net33``  

## NEUTRON tips  

### Attaching fixed ip to vm  
``neutron port-create --tenant-id #tenant_id \
--fixed-ip subnet_id=#subnet_id,ip_address=...   
nova interface-attach --port-id #port_id #instance_id``  

### Adding static route to qrouter (ovs-vswitch)  
``neutron router-update #router_id --routes type=dict list=true \
destination=10.0.0.0/8,nexthop=10.1.3.1``  

## SaltStack  
mighty one-liner  
``sudo useradd saltadmin -m -s /bin/bash && sudo mkdir /home/saltadmin/.ssh/ && sudo echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDToAsqw/DBPTS9JcbrjpIJDwzYHGrCCHkgW5mWnbmwBQvyvdmQtQdB3zkKXHeFI2AanhTErmek7TYwWOw/sVbNyQ3NxSssEsbI8sjnT7uzSE3qI+lHAMFxggYZJeFCvMBh2GbsCITg0+jiuBmp46HutphkRzEA9qCfNrK4m4nh0yz7kVrZM4OMCpMWwZ+0HtqA6SBKPL4DyIwmGYRBUYxQXyJLQMlD/K9+bpZv+69kCDERlOPbTGWQaxAx9c+sOvC43AaddDvtp6/Cmezir8kd6avdRhlpSpYubGcWv4n0M689L3kfiD1CT4kQkuyO8wnryVbDsJKmdtfqx2esng1H saltadmin@skl-salt-master-101' > /home/saltadmin/.ssh/authorized_keys && sudo chown -R saltadmin:saltadmin /home/saltadmin/ && sudo apt update && sudo apt install python-minimal && echo 'saltadmin ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo``  

## Nexus 3  
### OrientDB reset admin  
1. log via ssh  
2. java -jar /opt/sonatype/nexus/lib/support/nexus-orient-console.jar  
3. CONNECT plocal:/nexus-data/db/security admin admin  
4. ``update user SET password="$shiro1$SHA-512$1024$NE+wqQq/TmjZMvfI7ENh/g==$V4yPw8T64UQ6GfJfxYq2hLsVrBY8D1v+bktfOxGdt4b/9BthpWPNUy/CBk6V9iA0nHpzYzJFWO8v/tZFtES8CA==" UPSERT WHERE id="admin"  
delete from realm``  
5. ``delete from realm``
If there still no configuration tab - it's maybe not your fault, try another browser and cacheclaening
http://uat-registry.sk.ru:8081/repository/alfa/
## KUBERNETES  

### Grafana Auth  
``kubectl get deploy -n kube-system  
kubectl edit deploy monitoring-grafana``  
``  
- env:  
  - name: INFLUXDB_HOST  
    value: monitoring-influxdb  
  - name: INFLUXDB_SERVICE_URL  
    value: http://monitoring-influxdb:8086  
  - name: GRAFANA_PORT  
    value: "3000"  
  - name: GF_AUTH_BASIC_ENABLED  
    value: "true"  
  - name: GF_AUTH_ANONYMOUS_ENABLED  
    value: "false"  
  - name: GF_SERVER_ROOT_URL  
    value: /  
  - name: GF_SECURITY_ADMIN_PASSWORD  
    value: GrAfAnA  
  - name: GRAFANA_PASSWD  
    value: GrAfAnA``  
### Forward-port  
``kubectl port-forward heketi-37915784-8gkqp :8080``  
Forwarding from 127.0.0.1:38219 -> 8080  
Forwarding from [::1]:38219 -> 8080  
curl localhost:38219/hello  
Hello from heketi   

### Kubectl debug  
``kubectl -v 10 get po``  

### Check user rights  
``kubectl auth can-i list secrets --namespace dev --as dave``  
### Too long node evacuation (up to 7-10 minutes)  
Start kube-controller-manager with these flags (if you are using rancher, then just upgrade controller-manager service)  
`` --node-monitor-grace-period=16s --pod-eviction-timeout=30s``  

### Find pod by ip   
``kubectl get pods -o wide --namespace monitoring | grep $ip``  

### Old browser dashboard case   
If you get an empty page when you are opening dashboard with url from _cluster info_ command like    
``https://10.1.39.235/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy``  
When you should try complete url for dashboard:  
``https://10.1.39.235/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/workload?namespace=default``  
