---
layout: post  
title: OpenShift Ansible    
tags: openshift linux ansible
---

#### OpenShift Ansible origin/release-3.9  

### ON ALL HOSTS  
vim /etc/ssh/sshd_config - (permitRootLogin prohibit-password, PasswordAuthentication no;)  
vim /root/.ssh/authorized_keys - paste your key  
service sshd restart  
ssh-keygen  
vim /root/.ssh/authorized_keys - paste all  pub keys from all machines  

vim /etc/hosts - paste all hostnames, etc  
``1.1.1.39 os7.exampler.com  
1.1.1.69 os5.exampler.com  
1.1.1.74 os3.exampler.com  
1.1.1.83 os4.exampler.com  
1.1.1.37 os1.exampler.com  
1.1.1.56 os2.exampler.com``  

``for i in 1 2 3 4 5 7; do ssh -x os$i.exampler.com 'yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion epel-release docker PyYAML python-ipaddress; yum -y update'; done``    

vim docker (sample file, we will copy it to /etc/sysconfig)  
``OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false --insecure-registry 172.30.0.0/16'  
if [ -z "${DOCKER_CERT_PATH}" ]; then  
    DOCKER_CERT_PATH=/etc/docker  
fi``    
Copy file on all nodes:  
``for i in 1 2 3 4 5 7; do scp docker os$i.exampler.com:/etc/sysconfig/docker; systemctl restart docker; done  
for i in 1 2 3 4 5 7; do ssh -x os$i.exampler.com 'systemctl restart docker'; done``    

## On Deploy Node  

Setup DNS server  
``yum install -y epel-release   
yum install -y named ``  
vim /etc/named.cond  
``listen-on port 53 { any; };
allow-query     { any; };
zone "test-os.com" IN {
                type master;
                file "/etc/named/test-os.com.zone";
                allow-update { none; };
        };
``  
vim /etc/named/test-os.com.zone  
``$TTL 86400
@       IN  SOA     ns1.test-os.com. ns2.test-os.com. (
        2017011301      ;Serial
        3600    ;Refresh
        1800    ;Retry
        604800  ;Expire
        86400   ;Minimum TTL
)
        IN      NS      ns1.test-os.com.
        IN      NS      ns2.test-os.com.
        IN      MX      10 mail.test-os.com.

@       IN      A       10.220.106.245
ns1     IN      A       10.220.106.245
ns2     IN      A       10.220.106.245
oss     IN      A       10.220.106.250
mail    IN      A       10.220.106.245
www     IN      A       10.220.106.245
``
``systemctl enable named  
systemctl restart named  
firewall-cmd --permanent --add-port=53/tcp   
firewall-cmd --permanent --add-port=53/udp  
yum -y install ansible pyOpenSSL python-lxml java-1.8.0-openjdk-headless httpd-tools patch python2-passlib     
git clone https://github.com/openshift/openshift-ansible.git  
cd openshift-ansible   
git checkout remotes/origin/release-3.9``    
vim [hosts]({{"/listings/2018-08-03-OpenShift/hosts"}})  

NFS (on deployment host)  
``yum -y install nfs-utils nfs-utils-lib  
systemctl enable rpcbind  
systemctl enable nfs-server  
systemctl enable nfs-lock  
systemctl enable nfs-idmap  
systemctl start rpcbind  
systemctl start nfs-server  
systemctl start nfs-lock  
systemctl start nfs-idmap``  

add:    
openshift_master_htpasswd_file=/etc/origin/master/htpasswd  
``cat /etc/origin/master/htpasswd  
grafadmin:$apr1$gGoz5HDo$k7ft2vFTNXhWykxtdjead/  
test@com:$apr1$ehx/M4nF$0wd3uK7VFzLWc2pU1Segsd/  
cognoz:$apr1$d986J3RM$kCQfaztYcKOzBI2aPssdB.Ef.``  

``for i in 1.1.1.39 1.1.1.69 1.1.1.74 1.1.1.83 1.1.1.37 1.1.1.56; do ssh -x $i 'yum -y install NetworkManager; systemctl enable NetworkManager; systemctl start NetworkManager'; done``  

_SELINUX_  
ON ALL NODES   
vim /etc/default/grub    
``GRUB_CMDLINE_LINUX="consoleblank=0 fsck.repair=yes crashkernel=auto selinux=1 enforcing=1 rhgb quiet"  
grub2-mkconfig -o /boot/grub2/grub.cfg  
touch /.autorelabel  
OPTIONALLY -  
     useradd -m -s /bin/bash centos  
     cp -r /root/.ssh /home/centos/  
     chown -R centos:centos /home/centos``    
reboot  

## DEPLOY START  
_DEPLOY Node_  
``ansible-playbook -i hosts playbooks/prerequisites.yml  
ansible-playbook -i hosts playbooks/deploy_cluster.yml``    


ON MASTER  
``oc login -u system:admin  
oc get nodes``    

vim /etc/docker/daemon.json  
``{ "insecure-registries": ["172.30.0.0/16"] }``    

# Basic operations  
### Create new user  
``oc create user rklimenko  
oc adm policy add-cluster-role-to-user cluster-admin rklimenko  
htpasswd -c /etc/origin/master/htpasswd rklimenko  
``  
Log in on https://master_ip:8443  



# Trics  

### Change pvc without losing any data  
I foound it here https://bugzilla.redhat.com/show_bug.cgi?id=1570583  
``John Sanda 2018-06-05 10:46:12 EDT  
The big challenge with moving components to a new namespace is avoiding   data loss. Yesterday I asked on the aos-storage list how I can migrate data from a PV. Here are the detail steps with which I was   provided:  

1. Find your PV.  
2. Check PV.Spec.PersistentVolumeReclaimPolicy. If it Delete or Recycle,  
change it to Retain (`oc edit pv <xyz>` or `oc patch`)  

Whatever happens now, the worst thing that can happen to your PV is that  
it can get to Released phase. Data won't be deleted.  

Rebind:  
3. Create a new PVC in the new namespace. The new PVC should be the same  
as the old PVC - storage classes, labels, selectors, ... Explicitly,  
PVC.Spec.VolumeName *must* be set to PV.Name. This effectively turns   off  
dynamic provisioning for this PVC. The new PVC will be Pending. That's  
OK, the old PVC is still the one that's bound to the PV.  

4. Here comes the tricky part: change PV.Spec.ClaimRef exactly in this way:  
  PV.Spec.ClaimRef.Namespace = <new PVC namespace>  
  PV.Spec.ClaimRef.Name = <new PVC name>  
  PV.Spec.ClaimRef.UID = <new PVC UID>  

The old PVC should get "Lost" in couple of seconds (and you can safely  
delete it). New PVC should be "Bound". PV should be "Bound" to the new   PVC.  

5. Restore original PV.Spec.PersistentVolumeReclaimPolicy, if needed.  

Note that this just rebinds the PV. It does not stop pods in the old  
namespace that use the PV and start them in the new one. Something else  
must do that. You should delete the deployment first and re-create it in  
the new namespace when the new PVC is bound.``   

# BUGS  
### Incorrect image tag in metric rc (v3.9.0 not v.3.9)  
https://github.com/openshift/origin/issues/19440  
how to fix -
add to hosts this line  
``openshift_metrics_image_version=v3.9``  

### Problems with cassandra(hawkular metrics) create data dir -
Do NOT create exports in /etc/exports on nfs share manually - openshift  
will create them automatically in /etc/exports.d/openshift-ansible.exports  
If you have already created one - do following  on nfs share
``cat /dev/null > /etc/exports  
systemctl restart nfs-server``  
and this on the master node  
``oc login -u system:admin  
oc -n openshift-infra(or openshift-metrics)  delete po $hawkular-cassandra, $heapseter_pod $hawkular-metrics``  

### Problems with registry certificate   
see https://bugzilla.redhat.com/show_bug.cgi?id=1553838  
If you cant get working test app (oc new-app centos/ruby-22-centos7~https://github.com/openshift/ruby-ex.git)  
Because of this problem, you should do this on ALL (nodes / masters) nodes  
``ls -la /etc/docker/certs.d/docker-registry.default.svc\:5000/node-client-ca.crt  
rm -rf /etc/docker/certs.d/docker-registry.default.svc\:5000/node-client-ca.crt  
ln -s /etc/origin/node/ca.crt /etc/docker/certs.d/docker-registry.default.svc\:5000/node-client-ca.crt``  
and restart application  


### Problems with registry push (500) on nfs  
If you have this error  
``e="2018-08-08T11:26:19.218110887Z" level=error msg="response completed with error" err.code=unknown err.detail="filesystem: mkdir /registry: file exists" err.message="unknown error" go.version=go1.9.2``  
Then you should verify your nfs share  
example:  
cat /etc/exports.d/openshift-ansible.exports  
``"/var/nfs/registry" *(rw,root_squash)  
"/var/nfs/metrics/metrics" *(rw,root_squash)  
"/exports/logging-es" *(rw,root_squash)  
"/exports/logging-es-ops" *(rw,root_squash)  
"/exports/etcd" *(rw,root_squash)  
"/exports/prometheus" *(rw,root_squash)  
"/exports/prometheus-alertmanager" *(rw,root_squash)  
"/exports/prometheus-alertbuffer" *(rw,root_squash)``

DO NOT create anything in this dir manually!!!!  
If you have done this than you need to delete anything in this registry  
dir , restart nfs-server, recreate default pvc/pv for docker registry, recreate docker pods and recreate your app  
cat pv.yaml  

``apiVersion: v1  
kind: PersistentVolume  
metadata:  
  annotations:  
    pv.kubernetes.io/bound-by-controller: "yes"  
  name: registry-volume-volume  
spec:  
  accessModes:  
  - ReadWriteMany  
  capacity:  
    storage: 110Gi  
  nfs:  
    path: /var/nfs/registry  
    server: nfs-server-hostname  
  persistentVolumeReclaimPolicy: Retain``  
cat pvc.yaml  
``apiVersion: v1  
kind: PersistentVolumeClaim  
metadata:  
  annotations:  
    pv.kubernetes.io/bind-completed: "yes"  
    pv.kubernetes.io/bound-by-controller: "yes"  
  name: registry-volume-claim  
  namespace: default  
spec:  
  accessModes:  
  - ReadWriteMany  
  resources:  
    requests:  
      storage: 110Gi  
  storageClassName: ""  
  volumeName: registry-volume-volume``  

## PostDeploy  
Add compute label to nodes without it  
``oc project default  
oc get nodes -o wide  
oc label node node01.finomancer.com node-role.kubernetes.io/compute="true"  
oc label node node02.finomancer.com node-role.kubernetes.io/compute="true"``    

Add svc-ha label to compute nodes (it will be used for ipfailover)  
``for i in 1 2 3 4; do echo $i; oc describe nodes node0$i.finomancer.com | head -n 14; done  
for i in 1 2 3 4; do oc label node node0$i.finomancer.com ha-svc-nodes="failovervip"; done  
for i in 1 2 3 4; do echo $i; oc describe nodes node0$i.finomancer.com | head -n 14; done``  
