---
layout: post
title: External glusterfs integration with k8s
---
### Glusterfs cluster (replica 2) integration with k8s via heketi api  

### Components:
- Two VMs in Openstack, ubuntu 16.04:
_test-glusterfs-1 10.1.39.241  
test-glusterfs-2 10.1.39.240_  
- glustefs version: 3.12.1  
- keepalived 1.2.19  
- kubernetes (deployed previously via rancher 1.6.9)  

### Our aim is to get working HA persistent storage for K8S apps  

## Step 1. Initial configuration of OS  
_run on all nodes_  
``cat /etc/hosts  
127.0.0.1 localhost  
127.0.0.1 test-glusterfs-1  
10.1.39.241 test-glusterfs-1  
10.1.39.240 test-glusterfs-2``  

``add-apt-repository ppa:gluster/glusterfs-3.12  
apt update  
apt -y install glusterfs-server thin-provisioning-tools keepalived systemd  
service glusterd restart  
gluster peer probe test-glusterfs-1  
gluster peer probe test-glusterfs-2  
wget https://github.com/heketi/heketi/releases/download/v5.0.0/heketi-v5.0.0.linux.amd64.tar.gz  
tar -xf heketi-v5.0.0.linux.amd64.tar.gz  
cd heketi; cp heketi heketi-cli /usr/local/bin/  
groupadd -r -g 515 heketi  
useradd -r -c "Heketi user" -d /var/lib/heketi -s /bin/false -m -u 515 -g heketi heketi  
mkdir -p /var/lib/heketi && chown -R heketi:heketi /var/lib/heketi  
mkdir -p /var/log/heketi && chown -R heketi:heketi /var/log/heketi  
mkdir -p /etc/heketi  
ssh-keygen -f /etc/heketi/heketi_key -t rsa -N ''  
chown heketi:heketi /etc/heketi/heketi_key&ast;  
for i in 1 2; do ssh-copy-id -i /etc/heketi/heketi_key.pub root@test-glusterfs-$i; done``  

``cat /etc/ssh/sshd_config  
PermitRootLogin yes    
service ssh restart``  
### CHECK:  
``ssh -i /etc/heketi/heketi_key root@test-glusterfs-2``  

``cp /root/heketi/heketi.json /etc/heketi/heketi.json  
(raw file in the end of the post)  
mkdir /var/lib/heketi/db /var/lib/heketi/db_mount  
chown -R heketi:heketi /var/lib/heketi/``  

## Step 2. Volumes, neutron port, secgroups, keepalived
1. Create at least 2 volumes per VM in the Openstack (4 volumes, if you have 2 vm):  
``cinder create --name test-glusterfs-1-heketidb 10G  
cinder create --name test-glusterfs-2-heketidb 10G  
cinder create --name test-glusterfs-1-data 100G  
cinder create --name test-glusterfs-2-data 100G``  
2. Attach them to instances
``nova volume-attach $vm1_id test-glusterfs-1-heketidb  
nova volume-attach $vm2_id test-glusterfs-2-heketidb  
nova volume-attach $vm1_id test-glusterfs-1-data  
nova volume-attach $vm2_id test-glusterfs-2-data``  
3. Create and update neutron port for keepalived vip
``. openrc
export OS_TENANT_NAME='K8S-Lab'  
export OS_PROJECT_NAME='K8S-Lab'  
neutron port-create --fixed-ip subnet-id=$yournetid,ip_address=$kepalivedVIP $yournetid  
neutron port-update $VIP_portid --allowed-address-pairs type=dict list=true ip_address=VIP,mac_address=mac1 ip_address=VIP,mac_address=mac2  
neutrom port-update $vm1_porti --allowed-address-pairs type=dict list=true ip_address=$ip1,mac_address=vm1_mac   ip_address=$vip,mac_address=vm1_mac  
neutrom port-update $vm1_porti --allowed-address-pairs type=dict list=true ip_address=$ip2,mac_address=vm2_mac   ip_address=$vip,mac_address=vm2_mac``  
4. Create security groups in UI (convenient way)  
``vrrp - 112 tcp  
ssh - 22 tcp  
heketi - 8082 tcp``  
Assign all these groups to our instances (and default secgroup of course)  
Reboot instances  
5. ssh vm1 | ssh vm2
``vim /etc/keepalived/keepalived.conf (listing in the end of post)  
service keepalived restart  
ip -4 a  
ping $vip (it must be accessible from k8s)``  
###CHECK  
``shutdown -h now instance1; ip -4 a``  

## Step 3. LVM, Heketidb volume  
_run on all nodes_
``fdisk -l /dev/vd*; (find your 10G device with fdisk, let's assume that it is /dev/vdc)  
pvcreate /dev/vdc  
vgcreate heketidb-vg /dev/vdc  
lvcreate -n heketidb-lv -l 100%FREE heketidb-vg  
mkfs.xfs -i size=512 /dev/heketidb-vg/heketidb-lv  
vim /etc/fstab  
/dev/heketidb-vg/heketidb-lv /var/lib/heketi/db xfs defaults 0 0  
mount -a``  
_run on 1 node_    
``gluster volume create heketidb-vol replica 2 transport tcp test-glusterfs-1:/var/lib/heketi/db test-glusterfs-2:/var/lib/heketi/db force  
Again, vim /etc/fstab (node 1)  
test-glusterfs-1:heketidb-vol /var/lib/heketi/db_mount glusterfs defaults,\_netdev 0 0  
mount -a``  
_node 2_  
``test-glusterfs-2:heketidb-vol /var/lib/heketi/db_mount glusterfs defaults,\_netdev 0 0``  
_all nodes_  
``mount -a``  
### CHECK  
``mount | grep heketi``  

## Step 4. Heketi, Testing backend  
_run on all nodes_  
``vim /etc/systemd/system/heketi.service (listing in the end of post)  
vim /usr/local/sbin/notify-heketi.sh (listing in the end of post)  
chmod +x /usr/local/sbin/notify-heketi.sh  
service keepalived restart  
systemctl daemon-reload  
systemctl start heketi.service  
systemctl status heketi.service (one should be active and another not (conditional))``  
### CHECK  
``ls /var/lib/heketi/vip (it should exist on master node only)  
netstat -lutpn | grep 8082 (it should listen on master node only)  ``

_run on one node_  
``vim /etc/heketi/topology.json (listing in the end of post)  
export HEKETI_CLI_SERVER=http://$keepalive_vip:8082  
hekecti-cli --user admin --secret PASSWORD topology load /etc/heketi/topology.json``  
### CHECK  
``hekecti-cli --user admin --secret PASSWORD volume create --name test --size 10G --replica 2  
gluster volume list   
hekecti-cli --user admin --secret PASSWORD volume delete test``    
### Failover-CHECK  
``Shutdown instance with keepalived vip  
Check that ip now on backup server  
ls /var/lib/heketi/vip  
export HEKETI_CLI_SERVER=http://$keepalive_vip:8082  
hekecti-cli --user admin --secret PASSWORD volume list  
hekecti-cli --user admin --secret PASSWORD volume create --name test-ha --size 10G --replica 2  
hekecti-cli --user admin --secret PASSWORD volume delete test-ha  
Power on instance 1``  

## Step 5. Integration with K8S (all listings are in the end of post)
``Install kubectl(google it), mdkir ~/.kube, vim ~/.kube/config``  
### CHECK  
``kubectl get po``  
_run on the same node with kubectl_  
``mkdir k8s  
vim k8s/gluster-secret.yml  
vim k8s/gluster-heketi-external-storage-class.yml  
vim k8s/glusterfs-pvc-storageclass.yml  
echo -n "PASSWORD" >> k8s/gluster-secret.yml  
kubectl create -f *;``  
### CHECK
``kubectl get pvc - gluster-dyn-pvc should be BOUND``  

## Step 6. Deploying and testing in app
_run on the same node with kubectl_  
``vim k8s/nginx-deployment-pvc.yml  
kubectl create -f k8s/nginx-deployment-pvc.yml  
kubectl get po | grep nginx-deploy  
kubectl describe $podname - find out compute node on which our pod is running  
ssh $computenode  
docker ps | grep nginx-deploy  
docker exec -it -u root $id bash  
for i in {1..1000000}; do sleep 1; echo `date` >> /usr/share/nginx/html/omaigod; done``  
Now, while this shit is executing, we could shut off/reboot any glusterfs instance  
after some time, check this file in container:  
``cat /usr/share/nginx/html/omaigod``  
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

## LISTINGS:
[heketi.json]({{ "/listings/2017-10-11-extglusterk8s/heketi.json" }})  
[topology.json]({{ "/listings/2017-10-11-extglusterk8s/topology.json" }})  
[keepalived.conf]({{ "/listings/2017-10-11-extglusterk8s/keepalived.conf" }})  
[notify-heketi.sh]({{ "/listings/2017-10-11-extglusterk8s/notify-heketi.sh" }})  
[heketi.service]({{ "/listings/2017-10-11-extglusterk8s/heketi.service" }})  
[gluster-secret.yml]({{ "/listings/2017-10-11-extglusterk8s/gluster-secret.yml" }})  
[glusterfs-pvc-storageclass.yml]({{ "/listings/2017-10-11-extglusterk8s/glusterfs-pvc-storageclass.yml" }})  
[nginx-deployment-pvc.yml]({{ "/listings/2017-10-11-extglusterk8s/nginx-deployment-pvc.yml" }})  
