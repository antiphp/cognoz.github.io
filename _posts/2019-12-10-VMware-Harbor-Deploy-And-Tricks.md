---
layout: post  
title: Deploying and operating VMware Harbor registry  
tags: linux docker harbor registry
---


### Intro  
Mission: Deploy and operate VMware Harbor registry       

### Prerequisites  
- VM Ubuntu 18.04 (for test - 2cpu/2GB ram/60 GB hdd);

### Deployment   
#### Prepare harbor host  
SSH to harbor VM and begin:    
``ssh-keygen
echo 'ssh-rsa my-key'>> /root/.ssh/authorized_keys
apt update
apt install -y apt-transport-https ca-certificates curl software-properties-common openssl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt install docker-ce
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
systemctl status docker``  

Optionally, you can setup bip and log-opts for docker:  
``cat /etc/docker/daemon.json
{
  "bip": "199.199.199.1/24",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}``  
Don't forget to restart daemon after configuration:  
``systemctl restart docker``  

For notary service we need dns resolution and valid certificates for harbor host name.  
#### Let's start with hostname/hosts    
vim /etc/hosts
``10.220.104.57 harbor.cognoz harbor``  
vim /etc/hostname  
``harbor.cognoz``  
#### Update docker configuration for insecure registry:  
vim /etc/docker/daemon.json  
``{
  "bip": "199.199.199.1/24",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  },
  "insecure-registries" : ["harbor.cognoz","10.220.104.57"]
}``  
``systemctl restart docker``  
#### Next, we need to create self-signed certificates for our harbor server  
``mkdir -p /etc/harbor/certs
cd /etc/harbor/certs
cp /usr/lib/ssl/openssl.cnf ./``  
We need to customize openssl config for correct subjectAltName field in final cert   
vim openssl.cnf  
``req_extensions = v3_req
[ v3_req ]
subjectAltName = @alt_names
[alt_names] #paste it in the end of file  
DNS.1 = harbor.cognoz``  
Now we have everything for cert's generation:  
``openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt #main field - FQDN - it SHOULD be harbor.cognoz in this example  
openssl genrsa -out harbor.cognoz 2048
openssl req -new -sha256 -key harbor.cognoz -subj "/C=RU/ST=MS/O=ITKEY, LTD./CN=harbor.cognoz" -reqexts v3_req -config ./openssl.cnf -out``  
If you get error like this:
harbor.cognoz.csrCan't load /root/.rnd into RNG
139843715211712:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/root/.rnd  
Try to create file manually and run command again:    
``touch /root/.rnd
openssl req -new -sha256 -key harbor.cognoz -subj "/C=RU/ST=MS/O=ITKEY, LTD./CN=harbor.cognoz" -reqexts v3_req -config ./openssl.cnf -out``   

And finally:  
``openssl x509 -req -days 365 -in harbor.cognoz.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -CAserial serial_numbers -out harbor.cognoz.crt -extensions v3_req -extfile ./openssl.cnf``  

Validate:  
``openssl rsa -modulus -noout -in harbor.cognoz | openssl md5
openssl x509 -modulus -noout -in harbor.cognoz.crt | openssl md5``  

#### Harbor setup  
Download latest stable release:  
`` cd /opt/
wget https://github.com/goharbor/harbor/releases/download/v1.9.3/harbor-online-installer-v1.9.3.tgz
tar -xf harbor*
cd harbor``  
Configure:  
vim harbor.yml  
[harbor.yml]({{"/listings/2019-12-10-VMware-Harbor-Deploy-And-Tricks/multinode"}})  
If you want to use S3 storage backend, you can specify it in storage_service dict (harbor.yml):  
``storage_service:
  s3:
    accesskey: acc_key
    secretkey: secre_key
    region: us-east-1
    regionendpoint: http://10.220.104.58:9000
    bucket: harbor
    encrypt: false
    secure: false
    v4auth: true
    chunksize: 5242880
    rootdirectory: /``  


#### Add root-ca certificate to your host machine  
``scp root@10.220.104.57:/etc/harbor/certs/rootCA.crt Downloads/;``  
If you are using Windows OS, as I, you need to click on this certificate in downloads folder, and add it to trusted root certification centers.  

#### Install  
``cd /opt/harbor/  
./install.sh --with-notary --with-clair --with-chartmuseum``  

If everything went successful then you can access harbor registry on  https://10.220.104.57 (Or on https://harbor.cognoz if you have an corresponing entry in /etc/hosts)!
 








#### Generate passwords  
``kolla-genpwd``  
Optionally, change keystone_admin_password there to something shorter for convenience;  

#### Configure variables  
vim /etc/kolla/globals.yml  
[/etc/kolla/globals.yml]({{"/listings/2019-12-09-Kolla-Ansible-Train-Ext-Ceph/globals.yml"}})  
vim /opt/kolla-ansible/multinode
[/opt/kolla-ansible/multinode]({{"/listings/2019-12-09-Kolla-Ansible-Train-Ext-Ceph/multinode"}})    

#### Other checks  
In inventory file (multinode, for example), your nodes also should be placed under [baremetal:children] section (bootstrap).  

#### Bootstrap  
``kolla-ansible -i multinode bootstrap-servers``  

#### Deploy  
``kolla-ansible deploy -i multinode``  

#### Post-Deploy  
``kolla-ansible post-deploy``  

#### Check basic stuff  
If you installed kolla in venv, u also need openstack clients.  
``apt install -y build-essential python-dev
source /opt/venv/bin/activate
pip install openstackclient``  
Now, check basic statuses:  
``cinder service-list; nova service-list; neutron agent-list``  

### Links  
https://docs.openstack.org/kolla-ansible/latest/user/operating-kolla.html
