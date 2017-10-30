---
layout: post
title: NFS3 storage for K8S via ganesha+glusterfs  
tags: gluster kubernetes ganesha keepalived openstack systemctl  nfs    
---
### Glusterfs cluster (replica 2) integration with k8s via Ganesha+NFS3

### Components:
- Two VMs in Openstack, ubuntu 16.04:
_test-glusterfs-1 10.1.39.241  
test-glusterfs-2 10.1.39.240_  
- glustefs version: 3.12.1  
- keepalived 1.2.19  
- nfs-ganesha 2.5.3
- kubernetes (deployed previously via rancher 1.6.9)  

### Our aim is to get working HA persistent storage for K8S apps  

### WHY we should do it  
Some times ago i have written an article [External glusterfs integration with k8s]("https://cognoz.github.io/extglusterk8s/"). But several days ago i understanded that this scheme is a really big mess. Why i think so? I think so now because Heketi API deployed on baremetall nodes (not in the k8s cluster - it's a different story) has no fuc*ing idea about any process beneath it. So if i want to add a new node or remove a failed one(which is currently unaccessible) i can't do it.  ALL nodes should be online if you want anything. So there is no such thing as _HA_ (hahaha) or _failover_. I repeat that one more time  
### DO NOT USE HEKETI API ON 2 NODE CLUSTER OUTSIDE KUBERNETES! Never!###  

### SO YES WE ARE GOING NFS! ###    
## Step 1. Initial configuration of OS  
_run on all nodes_  
``cat /etc/hosts  
127.0.0.1 localhost  
127.0.0.1 test-glusterfs-1  
10.1.39.241 test-glusterfs-1  
10.1.39.240 test-glusterfs-2``  

``add-apt-repository ppa:gluster/glusterfs-3.12  
add-apt-repository ppa:gluster/libntirpc-1.5
add-apt-repository ppa:gluster/nfs-ganesha-2.5
apt update  
apt -y install glusterfs-server thin-provisioning-tools keepalived systemd  nfs-ganesha nfs-ganesha-gluster  
service glusterd restart  
gluster peer probe test-glusterfs-1  
gluster peer probe test-glusterfs-2``    

## Step 2. Volumes, neutron port, secgroups, keepalived
1. Create 2 volumes for both VM's in the Openstack:  
``cinder create --name test-glusterfs-1-data 300G  
cinder create --name test-glusterfs-2-data 300G``  
2. Attach them to instances  
``nova volume-attach $vm1_id test-glusterfs-1-data  
nova volume-attach $vm2_id test-glusterfs-2-data``  
3. Create and update neutron port for keepalived vip
``. openrc
export OS_TENANT_NAME='K8S-Lab'  
export OS_PROJECT_NAME='K8S-Lab'  
neutron port-create --fixed-ip subnet-id=$yournetid,ip_address=$kepalivedVIP $yournetid  
neutron port-update $VIP_portid --allowed-address-pairs type=dict list=true ip_address=VIP,mac_address=mac1 ip_address=VIP,mac_address=mac2  
``  
4. Create security groups in UI (convenient way)  
``vrrp - 112 tcp  
ssh - 22 tcp  
heketi - 8082 tcp  
nfs - 2049, 564,875 tcp and udp``  
Assign all these groups to our instances (and default secgroup of course)  
Reboot instances  
5. ssh vm1 | ssh vm2
vim [/etc/keepalived/keepalived.conf](/listings/2017-10-30-extglusterNFSk8s/keepalived.conf)  
vim [/etc/keepalived/ganeshacheck.sh](/listings/2017-10-30-extglusterNFSk8s/ganeshacheck.sh)
``chmod +x /etc/keepalived/ganeshacheck.sh  
service keepalived restart  
ip -4 a  
ping $vip (it must be accessible from k8s)``  
###CHECK  
``reboot instance1; ip -4 a  
OR  
service nfs-ganesha stop; ssh instance1 reboot  
##YOU shouldn't see vip on instance2 as far as ganesha is not running``  
ip should be active only if ganesha service UP, so you can stop nfs-ganesha service on slave and reboot master instance with VIP to test existence of vip on slave node    

## Step 3. LVM  
_run on all nodes_
``lsblk; (find your 300G DATA device with fdisk, let's assume that it is /dev/vdc)  
pvcreate /dev/vdc  
vgcreate glustervg /dev/vdc  
lvcreate -n glusterlv -l 100%FREE glustervg  
mkfs.xfs -i size=512 /dev/glustervg/glusterlv  
mkdir -p /opt/gluster/gluster``  
vim /etc/fstab  
``/dev/mapper/glustervg-glusterlv /opt/gluster xfs defaults 0 0``  
``mount -a``   
_run on 1 node_    
``gluster volume create data-1 replica 2 transport tcp test-glusterfs-1:/opt/gluster/gluster  test-glusterfs-2:/opt/gluster/gluster force``  

### CHECK  
``mount | grep gluster``   

## Step 4. Ganesha configuration  
_run on all nodes_  
vim [/etc/ganesha/ganesha.conf](/listings/2017-10-30-extglusterNFSk8s/ganesha.conf)  
vim [/etc/ganesha/gluster.conf](/listings/2017-10-30-extglusterNFSk8s/gluster.conf)  
vim /lib/systemd/system/nfs-ganesha-config.service:  
``ExecStart=/usr/lib/nfs-ganesha-config.sh``  
``chmod +x /usr/lib/nfs-ganesha-config.sh; systemctl daemon-reload; systemctl restart nfs-ganesha.service``  
### CHECK  
`` mkdir /tmp/dirt; mount -t nfs VIP:/volname(from gluster.conf) /tmp/dirt``    


## Step 5. Integration with K8S  
``Install kubectl(google it), mdkir ~/.kube, vim ~/.kube/config``  
### CHECK  
``kubectl get po``  
_on all COMPUTE nodes_  
``apt -y install nfs-common``  
_run on the same node with kubectl_  
``mkdir k8s``  
vim k8s/[glusterfs-pv-nfs.yml](/listings/2017-10-30-extglusterNFSk8s/gluster-pv-nfs.yml)  
vim k8s/[glusterfs-pvc-nfs.yml](/listings/2017-10-30-extglusterNFSk8s/glusterfs-pvc-nfs.yml)  
vim k8s/[nginx-deployment-pvc-nfs.yml](/listings/2017-10-30-extglusterNFSk8s/nginx-deployment-pvc-nfs.yml)  
``kubectl create -f *``  
### CHECK  
``kubectl get pvc - nfs should be BOUND``  

## Step 6. Deploying and testing in app  
_run on the same node with kubectl_  
``kubectl get po | grep nginx-deploy  
kubectl describe $podname - find out compute node on which our pod is running  
ssh $computenode  
docker ps | grep nginx-deploy  
docker exec -it -u root $id bash  
for i in {1..1000000}; do sleep 1; echo `date` >> /usr/share/nginx/html/omaigod; done``  
Now, while this shit is executing, we could shut off/reboot any glusterfs instance  
after some time, check this file in container:  
``cat /usr/share/nginx/html/omaigod``  

## Step 6.5.  If not _all_ pods are running  
If you are experiencing some problems with mounting volumes inside pods, you can try this thing:  
``ssh compute{1...};  mount -t nfs vip:/volume /opt/; umount /opt/``  
Just run this easy operations and after several moments all pods will be running.     
## Step 7. Benchmarking glusterfs  
``cat generate.sh  
cat generate.sh  
for i in $(seq 1 $NUMBER);  
do  
dd if=/dev/urandom of=$TARGET/file_$i bs=$SIZE count=$COUNT 2>&1 | grep -v records  
done``  
#### Creating 10240 files of 100k
``export NUMBER=10240  
export COUNT=1  
export TARGET=pwd/100k  
export SIZE=100K  
sh generate.sh > 100k.log``  

#### Creating 1024 files of 1M
``export NUMBER=1024  
export TARGET=pwd/1M  
export SIZE=1M  
sh generate.sh > 1M.log ``  

#### Creating 100 files of 10M
``export NUMBER=100  
export TARGET=pwd/10M  
export SIZE=10M  
sh generate.sh > 10M.log``  

#### Creating 10 files of 100M
``export NUMBER=10  
export COUNT=100  
export TARGET=pwd/100M  
export SIZE=1M  
sh generate.sh > 100M.log``  

#### Creating 1 file of 1G
``export NUMBER=1  
export TARGET=pwd/1G  
export SIZE=1M  
export COUNT=1024  
sh generate.sh > 1G.log``  

#### Average:
``cat 1M_root.log | awk '{print $8}' | awk '{a+=$1} END{print a/NR}' > 1M_root.result``   
