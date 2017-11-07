---
layout: post
title: NFS3 storage for K8S via ganesha+glusterfs  
tags: gluster kubernetes ganesha keepalived openstack systemctl  nfs    
---
### Glusterfs cluster (replica 2) integration with k8s via Ganesha+NFS3

### Components:
- Two VMs in Openstack, centos 7:
_test-glusterfs-1 10.1.39.241  
test-glusterfs-2 10.1.39.240_  
- glustefs version: 3.10  
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
10.1.39.240 test-glusterfs-2  
10.1.39.242 test-glusterfs-3  
10.1.39.211 test-glusterfs-1v  
10.1.39.212 test-glusterfs-2v``    

``sudo passwd root  
su  
yum install -y centos-release-gluster310.noarch vim    
yum install -y glusterfs glusterfs-server  nfs-ganesha  nfs-ganesha-gluster glusterfs-geo-replication
systemctl enable glusterd && systemctl start glusterd  
setenforce 0    
gluster peer probe test-glusterfs-1  
gluster peer probe test-glusterfs-2  
gluster peer probe test-glusterfs-3``    
_run on first and second nodes_  
``yum install pcs``  
vim [/etc/corosync/corosync.conf](/listings/2017-10-30-extglusterNFSk8s/corosync.conf)  
``systemctl enable pcsd && systemctl start pcsd
systemctl enable pacemaker && systemctl start pacemaker
systemctl enable corosync && systemctl start corosync
echo hapassword | passwd --stdin hacluster``
Use loginpair (hacluster:hapassord) for next commands
_run on one (1st or 2d) node_      
``pcs cluster auth test-glusterfs-1  
pvs cluster auth test-glusterfs-2 ``  

## Step 2. Volumes, neutron port, secgroups, keepalived
1. Create 2 volumes for both VM's in the Openstack:  
``cinder create --name test-glusterfs-1-data 300G  
cinder create --name test-glusterfs-2-data 300G  
cinder create --name test-glusterfs-3-meta 10G``    
2. Attach them to instances  
``nova volume-attach $vm1_id test-glusterfs-1-data  
nova volume-attach $vm2_id test-glusterfs-2-data  
nova volume-attach $vm3_id test-glusterfs-3-meta``  
3. Create and update neutron ports for pcs vip resources  
``. openrc
export OS_TENANT_NAME='K8S-Lab'  
export OS_PROJECT_NAME='K8S-Lab'  
neutron port-create --fixed-ip subnet-id=$yournetid,ip_address=test-glusterfs-1v_IP $yournetid  
neutron port-update $test-glusterfs-1v_IP_portid --allowed-address-pairs type=dict list=true   ip_address=VIP,mac_address=mac1 ip_address=VIP,mac_address=mac2  
neutron port-create --fixed-ip subnet-id=$yournetid,ip_address=test-glusterfs-2v_IP $yournetid  
neutron port-update $test-glusterfs-2v_IP_portid --allowed-address-pairs type=dict list=true ip_address=VIP,mac_address=mac1 ip_address=VIP,mac_address=mac2  
neutron port-update $VM1_portid --allowed-address-pairs type=dict list=true   ip_address=$VM1_ip,mac_address=$VM1_mac ip_address=$test-glusterfs-1v_IP,mac_address=$VM1_mac ip_addres=$test-glusterfs-2v_IP,mac_address=$VM1_mac  
neutron port-update $VM2_portid --allowed-address-pairs type=dict list=true   ip_address=$VM2_ip,mac_address=$VM2_mac ip_address=$test-glusterfs-1v_IP,mac_address=$VM2_mac ip_addres=$test-glusterfs-2v_IP,mac_address=$VM2_mac  
``  
4. Create security groups in UI (convenient way)  
``vrrp - 112 tcp  
ssh - 22 tcp  
heketi - 8082 tcp  
nfs - 2049, 564,875 tcp and udp``  
Assign all these groups to our instances (and default secgroup of course)  
Reboot instances      
## Step 3. LVM  
_run on all nodes_
``lsblk; (find your 300G DATA device with fdisk, let's assume that it is /dev/vdc)  
pvcreate /dev/vdc  
vgcreate glustervg /dev/vdc  
lvcreate -n glusterlv -l 100%FREE glustervg  
mkfs.xfs -i size=512 /dev/glustervg/glusterlv  
mkdir -p /opt/gluster/vol``  
vim /etc/fstab  
``/dev/mapper/glustervg-glusterlv /opt/gluster/vol xfs defaults 0 0``  
``mount -a  
mkdir /opt/gluster/vol/gluster``
## Step 4. SSH configuration  
vim /etc/ssh/sshd_config  
``PermitRootLogin yes  
PasswordAuthentication yes``  
``service sshd restart``  
_run on first node_    
``ssh-keygen -f /var/lib/glusterd/nfs/secret.pem  
ssh-copy-id -i /var/lib/glusterd/nfs/secret.pem.pub root@test-nfs-rk-1  
ssh-copy-id -i /var/lib/glusterd/nfs/secret.pem.pub root@test-nfs-rk-2  
ssh-copy-id -i /var/lib/glusterd/nfs/secret.pem.pub root@test-nfs-rk-3  
scp /var/lib/glusterd/nfs/secret.* root@test-nfs-rk-3:/var/lib/glusterd/nfs/  
scp /var/lib/glusterd/nfs/secret.* root@test-nfs-rk-2:/var/lib/glusterd/nfs/``  
_run on all nodes_  
``ssh -i /var/lib/glusterd/nfs/secret.pem root@test-nfs-rk-1  
exit  
ssh -i /var/lib/glusterd/nfs/secret.pem root@test-nfs-rk-2  
exit  
ssh -i /var/lib/glusterd/nfs/secret.pem root@test-nfs-rk-3    
exit``   

_run on first node_  
vim [/etc/ganesha/ganesha-ha.conf](/listings/2017-10-30-extglusterNFSk8s/ganesha-ha.conf)  
``gluster volume set all cluster.enable-shared-storage enable``  
wait for a moment  
_run on all nodes_  
``setenforce 0``
_run on one node_  
``gluster volume remove-brick gluster_shared_storage replica 2 test-glusterfs-3:/var/lib/glusterd/ss_brick  
!!!!!!!gluster volume add-brick gluster_shared_storage replica 3 arbiter 1 test-nfs-rk-3:/var/lib/glusterd/ss_brick force !!!!!!
gluster volume create cluster-demo replica 3 arbiter 1 test-nfs-rk-1:/opt/gluster/vol/gluster/ test-nfs-rk-2:/opt/gluster/vol/gluster/ test-nfs-rk-3:/opt/gluster/vol/gluster/ force  
``  
``mkdir /etc/ganesha/bak/``  
vim [/etc/ganesha/bak/ganesha.conf](/listings/2017-10-30-extglusterNFSk8s/ganesha-ha.conf)  
start ganesha-ha creation  
``gluster nfs-ganesha enable``  
debug config  
``crm_verify -LV``    
if you have error with stonith when run  
``pcs property set stonith-enabled=false``  
if you have this error: _Error: creation of symlink ganesha.conf in /etc/ganesha failed_  
when you should disable selinux  
vim /etc/selinux/config   
``SELINUX=disabled  
reboot``  

``gluster volume create data-1 replica 2 transport tcp test-glusterfs-1:/opt/gluster/vol/gluster  test-glusterfs-2:/opt/gluster/vol/gluster test-glusterfs-3:/opt/gluster/vol/gluster force``  
``
### CHECK  
``mount | grep gluster``   

## Step 4. Ganesha configuration  
_run on all nodes_  
vim [/etc/ganesha/ganesha.conf](/listings/2017-10-30-extglusterNFSk8s/ganesha.conf)  
vim [/etc/ganesha/gluster.conf](/listings/2017-10-30-extglusterNFSk8s/gluster.conf)  
vim [/lib/systemd/system/nfs-ganesha.service](/listings/2017-10-30-extglusterNFSk8s/ganesha.service)   
### CHECK  
`` mkdir /tmp/dirt; mount -t nfs VIP:/volname(from gluster.conf) /tmp/dirt``    

### IMPORTANT   
1. systemctl enable corosync.service  && systemctl enable pacemaker.service && systemctl enable nfs-ganesha.service   
2. Sle
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

## Tear down cluster  
`` ssh node1; gluster nfs-ganesha dsable  
pcs cluster node remove $node1  
ssh node2  
pcs cluster node remove $node2``  
