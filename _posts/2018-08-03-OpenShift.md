### General tips  
#### OpenShift Ansible origin/release-3.9  

### ON ALL HOSTS  
vim /etc/ssh/sshd_config - (permitRootLogin prohibit-password, PasswordAuthentication no;)  
vim /root/.ssh/authorized_keys - paste your key  
service sshd restart  
ssh-keygen  
vim /root/.ssh/authorized_keys - paste all  pub keys from all machines  

vim /etc/hosts - paste all hostnames, etc  
1.1.1.39 os7.exampler.com  
1.1.1.69 os5.exampler.com  
1.1.1.74 os3.exampler.com  
1.1.1.83 os4.exampler.com  
1.1.1.37 os1.exampler.com  
1.1.1.56 os2.exampler.com  

for i in 1 2 3 4 5 7; do ssh -x os$i.exampler.com 'yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion epel-release docker PyYAML python-ipaddress; yum -y update'; done  

vim docker  
``# /etc/sysconfig/docker  

OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false --insecure-registry 172.30.0.0/16'  
if [ -z "${DOCKER_CERT_PATH}" ]; then  
    DOCKER_CERT_PATH=/etc/docker  
fi``  

for i in 1 2 3 4 5 7; do scp docker os$i.exampler.com:/etc/sysconfig/docker; systemctl restart docker; done  
for i in 1 2 3 4 5 7; do ssh -x os$i.exampler.com ‘systemctl restart docker’; done  

## Deploy Node  

yum -y install ansible pyOpenSSL python-lxml java-1.8.0-openjdk-headless httpd-tools patch python2-passlib     
git clone https://github.com/openshift/openshift-ansible.git  
cd openshift-ansible   
git checkout remotes/origin/release-3.9  

vim [hosts]({{"/listings/2018-08-03-OpenShift/hosts"}})  

NFS (on deployment host)  
yum -y install nfs-utils nfs-utils-lib  
systemctl enable rpcbind  
systemctl enable nfs-server  
systemctl enable nfs-lock  
systemctl enable nfs-idmap  
systemctl start rpcbind  
systemctl start nfs-server  
systemctl start nfs-lock  
systemctl start nfs-idmap  

vim /etc/exports  
/var/nfs 1.1.1.0/24 (rw,sync,no_root_squash,no_all_squash)  
systemctl restart nfs  
mkdir tst; mount -t nfs localhost:/var/nfs tst/;  
mkdir tst/registry; mkdir tst/metrics  
umount tst  


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
``{ “insecure-registries”: [“172.30.0.0/16”] }``    
