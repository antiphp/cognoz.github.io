---
layout: post
title: External glusterfs integration with k8s
---
## Replica 2 glusterfs cluster integration with k8s via heketi api
complex tash  :weary:

###Artifacts:
https://cloud.mail.ru/public/C5ns/pvCutmFa7

###Components:

two VMs in Openstack, ubuntu 16.04:
test-glusterfs-1 10.1.39.241
test-glusterfs-2 10.1.39.240
glustefs version: 3.12.1
keepalived 1.2.19
kubernetes (deployed previously via rancher 1.6.9)

###Our aim is to get working HA persistent storage for K8S apps.

##Step 1. Initial configuration of OS
(All nodes)
cat /etc/hosts
127.0.0.1 localhost
127.0.0.1 test-glusterfs-1
10.1.39.241 test-glusterfs-1
10.1.39.240 test-glusterfs-2

add-apt-repository ppa:gluster/glusterfs-3.12
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
for i in 1 2; do ssh-copy-id -i /etc/heketi/heketi_key.pub root@test-glusterfs-$i; done
cat /etc/ssh/sshd_config
PermitRootLogin yes

service ssh restart
###CHECK: ssh -i /etc/heketi/heketi_key root@test-glusterfs-2
cp /root/heketi/heketi.json /etc/heketi/heketi.json
(raw file in the end of the post)
mkdir /var/lib/heketi/db /var/lib/heketi/db_mount
chown -R heketi:heketi /var/lib/heketi/

##Step 2. Volumes, neutron port, secgroups, keepalived

1. Create at least 2 volumes per VM in the Openstack (4 volumes, if you have 2 vm):
cinder create --name test-glusterfs-1-heketidb 10G
cinder create --name test-glusterfs-2-heketidb 10G
cinder create --name test-glusterfs-1-data 100G
cinder create --name test-glusterfs-2-data 100G
2. Attach them to instances
nova volume-attach $vm1_id test-glusterfs-1-heketidb
nova volume-attach $vm2_id test-glusterfs-2-heketidb
nova volume-attach $vm1_id test-glusterfs-1-data
nova volume-attach $vm2_id test-glusterfs-2-data
3. Create and update neutron port for keepalived vip
. openrc
export OS_TENANT_NAME='K8S-Lab'
export OS_PROJECT_NAME='K8S-Lab'
neutron port-create --fixed-ip subnet-id=$yournetid,ip_address=$kepalivedVIP $yournetid
neutron port-update $VIP_portid --allowed-address-pairs type=dict list=true ip_address=VIP,mac_address=mac1 ip_address=VIP,mac_address=mac2
neutrom port-update $vm1_porti --allowed-address-pairs type=dict list=true ip_address=$ip1,mac_address=vm1_mac ip_address=$vip,mac_address=vm1_mac
neutrom port-update $vm1_porti --allowed-address-pairs type=dict list=true ip_address=$ip2,mac_address=vm2_mac ip_address=$vip,mac_address=vm2_mac
4. Create security groups in UI (convenient way)
vrrp - 112 tcp
ssh - 22 tcp
heketi - 8082 tcp
Assign all these groups to our instances (and default secgroup of course)
Reboot instances
5. ssh vm1 | ssh vm2
vim /etc/keepalived/keepalived.conf (listing in the end of post)
service keepalived restart
ip -4 a
ping $vip (it must be accessible from k8s)
CHECK: shutdown -h now instance1; ip -4 a

##Step 3. LVM, Heketidb volume
(All nodes)
fdisk -l /dev/vd&ast; (find your 10G device with fdisk, let's assume that it is /dev/vdc)
pvcreate /dev/vdc
vgcreate heketidb-vg /dev/vdc
lvcreate -n heketidb-lv -l 100%FREE heketidb-vg
mkfs.xfs -i size=512 /dev/heketidb-vg/heketidb-lv
vim /etc/fstab
/dev/heketidb-vg/heketidb-lv /var/lib/heketi/db xfs defaults 0 0
mount -a
(On one node):
gluster volume create heketidb-vol replica 2 transport tcp test-glusterfs-1:/var/lib/heketi/db test-glusterfs-2:/var/lib/heketi/db force
Again, vim /etc/fstab (node 1)
test-glusterfs-1:heketidb-vol /var/lib/heketi/db_mount glusterfs defaults,\_netdev 0 0
mount -a
(node 2)
test-glusterfs-2:heketidb-vol /var/lib/heketi/db_mount glusterfs defaults,\_netdev 0 0
mount -a
###CHECK: mount | grep heketi

##Step 4. Heketi, Testing backend
(All nodes)
vim /etc/systemd/system/heketi.service (listing in the end of post)
vim /usr/local/sbin/notify-heketi.sh (listing in the end of post)
chmod +x /usr/local/sbin/notify-heketi.sh
service keepalived restart
systemctl daemon-reload
systemctl start heketi.service
systemctl status heketi.service (one should be active and another not (conditional))
###CHECK:
ls /var/lib/heketi/vip (it should exist on master node only)
netstat -lutpn | grep 8082 (it should listen on master node only)

(one node):
vim /etc/heketi/topology.json (listing in the end of post)
export HEKETI_CLI_SERVER=http://$keepalive_vip:8082
hekecti-cli --user admin --secret PASSWORD topology load /etc/heketi/topology.json

###CHECK: hekecti-cli --user admin --secret PASSWORD volume create --name test --size 10G --replica 2
gluster volume list
hekecti-cli --user admin --secret PASSWORD volume delete test
Failover-CHECK:
Shutdown instance with keepalived vip
Check that ip now on backup server
ls /var/lib/heketi/vip
export HEKETI_CLI_SERVER=http://$keepalive_vip:8082
hekecti-cli --user admin --secret PASSWORD volume list
hekecti-cli --user admin --secret PASSWORD volume create --name test-ha --size 10G --replica 2
hekecti-cli --user admin --secret PASSWORD volume delete test-ha
Power on instance 1

##Step 5. Integration with K8S (all listings are in the end of post)

Install kubectl, mdkir ~/.kube, vim ~/.kube/config
CHECK: kubectl get po
mkdir k8s
vim k8s/gluster-secret.yml
vim k8s/gluster-heketi-external-storage-class.yml
vim k8s/glusterfs-pvc-storageclass.yml
echo -n "PASSWORD" >> k8s/gluster-secret.yml
kubectl create -f &ast;
CHECK: kubectl get pvc - gluster-dyn-pvc should be BOUND

##Step 6. Deploying and testing in app
vim k8s/nginx-deployment-pvc.yml
kubectl create -f k8s/nginx-deployment-pvc.yml
kubectl get po | grep nginx-deploy
kubectl describe $podname - find out compute node on which our pod is running
ssh $computenode
docker ps | grep nginx-deploy
docker exec -it -u root $id bash
for i in {1..1000000}; do sleep 1; echo `date` >> /usr/share/nginx/html/omaigod; done
Now, while this shit is executing, we could shut off/reboot any glusterfs instance
after some time, check this file in container /usr/share/nginx/html/omaigod

##Step 7. Benchmarking glusterfs
cat generate.sh

cat generate.sh
for i in $(seq 1 $NUMBER);
do
dd if=/dev/urandom of=$TARGET/file_$i bs=$SIZE count=$COUNT 2>&1 | grep -v records
done
#### Creating 10240 files of 100k
export NUMBER=10240
export COUNT=1
export TARGET=pwd/100k
export SIZE=100K
sh generate.sh > 100k.log

####Creating 1024 files of 1M

export NUMBER=1024
export TARGET=pwd/1M
export SIZE=1M
sh generate.sh > 1M.log

####Creating 100 files of 10M

export NUMBER=100
export TARGET=pwd/10M
export SIZE=10M
sh generate.sh > 10M.log

####Creating 10 files of 100M

export NUMBER=10
export COUNT=100
export TARGET=pwd/100M
export SIZE=1M
sh generate.sh > 100M.log

####Creating 1 file of 1G

export NUMBER=1
export TARGET=pwd/1G
export SIZE=1M
export COUNT=1024
sh generate.sh > 1G.log

####Average:
cat 1M_root.log | awk '{print $8}' | awk '{a+=$1} END{print a/NR}' > 1M_root.result

##LISTINGS:
cat /etc/heketi/heketi.json
{
"\_port_comment": "Heketi Server Port Number",
"port": "8082",
"\_use_auth": "Enable JWT authorization. Please enable for deployment",
"use_auth": true,
"\_jwt": "Private keys for access",
"jwt": {
"\_admin": "Admin has access to all APIs",
"admin": {
"key": "PASSWORD"
},
"\_user": "User only has access to /volumes endpoint",
"user": {
"key": "dXNlcl9wYXNzd29yZAo="
}
},
"\_backup_db_to_kube_secret": "Backup the heketi database to a Kubernetes secret when running in Kubernetes. Default is off.",
"backup_db_to_kube_secret": false,
"\_glusterfs_comment": "GlusterFS Configuration",
"glusterfs": {
"\_executor_comment": [
"Execute plugin. Possible choices: mock, ssh",
"mock: This setting is used for testing and development.",
" It will not send commands to any node.",
"ssh: This setting will notify Heketi to ssh to the nodes.",
" It will need the values in sshexec to be configured.",
"kubernetes: Communicate with GlusterFS containers over",
" Kubernetes exec api."
],
"executor": "ssh",
"\_sshexec_comment": "SSH username and private key file information",
"sshexec": {
"keyfile": "/etc/heketi/heketi_key",
"user": "root",
"port": "22",
"fstab": "/etc/fstab"
},
"\_kubeexec_comment": "Kubernetes configuration",
"kubeexec": {
"host" :"https://kubernetes.host:8443",
"cert" : "/path/to/crt.file",
"insecure": false,
"user": "kubernetes username",
"password": "password for kubernetes user",
"namespace": "OpenShift project or Kubernetes namespace",
"fstab": "Optional: Specify fstab file on node. Default is /etc/fstab"
},
"\_db_comment": "Database file name",
"db": "/var/lib/heketi/db_mount/heketi.db",
"\_loglevel_comment": [
"Set log level. Choices are:",
" none, critical, error, warning, info, debug",
"Default is warning"
],
"loglevel" : "debug"
}
}

cat /etc/heketi/topology.json
{
"clusters": [
{
"nodes": [
{
"node": {
"hostnames": {
"manage": [
"test-glusterfs-1"
],
"storage": [
"10.1.39.241"
]
},
"zone": 1
},
"devices": [
"/dev/vdd"
]
},
{
"node": {
"hostnames": {
"manage": [
"test-glusterfs-2"
],
"storage": [
"10.1.39.240"
]
},
"zone": 2
},
"devices": [
"/dev/vdd"
]
}
]
}
]
}

cat /etc/keepalived/keepalived.conf
vrrp_instance VIP_1 {
state MASTER
interface ens3
virtual_router_id 100
priority 200
notify /usr/local/sbin/notify-heketi.sh
advert_int 1
authentication {
auth_type PASS
auth_pass supersecretpassword
}
virtual_ipaddress {
10.1.39.202
}
}

cat /usr/local/sbin/notify-heketi.sh
#!/bin/bash
TYPE=$1
NAME=$2
STATE=$3
case $STATE in
"MASTER") /usr/bin/touch /var/lib/heketi/vip
/bin/systemctl start heketi.service
/usr/bin/logger "$1 $2 $3 master state"
;;
"BACKUP") /bin/rm -rf /var/lib/heketi/vip
/bin/systemctl stop heketi.service
/usr/bin/logger "$1 $2 $3 $4 stopped state"
;;
"FAULT") /bin/rm -rf /var/lib/heketi/vip
/bin/systemctl stop heketi.service
/usr/bin/logger "$1 $2 $3 $4 fault state"
exit 0
;;
&ast;) /bin/rm -rf /var/lib/heketi/vip
/usr/bin/logger "$1 $2 $3 $4 unknown state"
exit 1
;;
esac

cat /etc/systemd/system/heketi.service
[Unit]
Description=Heketi Server
Requires=network-online.target
After=network-online.target
ConditionPathIsMountPoint=/var/lib/heketi/db_mount
ConditionPathExists=/var/lib/heketi/vip

[Service]
Type=simple
User=heketi
Group=heketi
PermissionsStartOnly=true
PIDFile=/run/heketi/heketi.pid
Restart=always
RestartSec=3
WorkingDirectory=/var/lib/heketi
RuntimeDirectory=heketi
RuntimeDirectoryMode=0755
ExecStartPre=/bin/rm -f /run/heketi/heketi.pid
ExecStart=/usr/local/bin/heketi --config=/etc/heketi/heketi.json
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target

cat gluster-secret.yml
apiVersion: v1
kind: Secret
metadata:
name: heketi-secret
namespace: default
type: "kubernetes.io/glusterfs"
data:
# echo -n "PASSWORD" | base64
key: UEFTU1dPUkQ=

cat gluster-heketi-external-storage-class.yml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
name: gluster-heketi-external
provisioner: kubernetes.io/glusterfs
parameters:
resturl: "http://10.1.39.202:8082"
restuser: "admin"
secretName: "heketi-secret"
secretNamespace: "default"
volumetype: "replicate:2"

cat glusterfs-pvc-storageclass.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: gluster-dyn-pvc
annotations:
volume.beta.kubernetes.io/storage-class: gluster-heketi-external
spec:
accessModes:
- ReadWriteMany
resources:
requests:
storage: 20Gi

cat nginx-deployment-pvc.yml
kind: Service
apiVersion: v1
metadata:
name: fronten-nginx
spec:
selector:
app: nginxxx
tier: frontend
ports:
- protocol: "TCP"
port: 80
nodePort: 30300
targetPort: 80
type: NodePort
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
name: nginx-deployment
spec:
selector:
matchLabels:
app: nginxxx
replicas: 2 # tells deployment to run 2 pods matching the template
template: # create pods using pod definition in this template
metadata:
# unlike pod-nginx.yaml, the name is not included in the meta data as a unique name is
# generated from the deployment name
labels:
app: nginxxx
spec:
containers:
- name: nginx
image: nginx
volumeMounts:
- name: gluster-vol1
mountPath: /usr/share/nginx/html
image: nginx
ports:
- containerPort: 80
volumes:
- name: gluster-vol1
persistentVolumeClaim:
claimName: gluster-dyn-pvc
