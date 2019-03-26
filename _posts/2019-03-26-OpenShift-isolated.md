---
layout: post  
title: Deploying OpenShift in isolated infrastructure
tags: openshift linux ansible
---


### Intro  
Mission: Deploy OpenShift OKD in isolated infrastructure.

### Prerequisites  
VM with these roles (hardware listed for dev env):  
- 5 masters; \#8cpu, 16ram, 100hdd
- 5 etcd; \#8 cpu, 12ram, 100ssd
- 3 infra nodes (with lb); \#4 cpu, 16ram, 50hdd
- 3 worker nodes; \#4cpu, 12ram, 150hdd
- 1 Nexus VM; \# will be used for all envs, so: 16cpu, 32ram, 22hdd root + 300hdd for data  

Pre-installed CentOS 7.6 on all VM's (in our case - via Vsphere Terraform plugin)  
HTTPS Proxy for pulling images  
Mirrors for rpm packages  

### Prepare ansible vm  
``ssh deployvm
cp mirrors.repo /etc/yum.repos.d/
yum makecache fast``  
list of repos to be mirrored:  
``name=CentOS OpenShift Origin 3.11
name=CentOS-$releasever - Base
name=CentOS-$releasever - Updates
name=CentOS-$releasever - Extras
name=CentOS OpenShift Origin
name=CentOS Ansible 2.6 testing repo
name=CentOS OpenShift Origin 3.11
name=CentOS-$releasever - Base
name=CentOS-$releasever - Updates
name=CentOS-$releasever - Extras
name=CentOS OpenShift Origin
name=CentOS Ansible 2.6 testing repo``  

Clone OKD repo, install required packages
(in case of existing https_proxy but without pip mirrors)  
``ssh deployvm  
export https_proxy='http://user:pass@PROXY_ADDRESS:PROXY_PORT'  
cd /opt/
git clone https://github.com/openshift/openshift-ansible.git -b release-3.11 ./
cd openshift-ansible  
pip install -r requirements.txt``    
vim [inventory/test-env]({{"/listings/2019-03-26-OpenShift-isolated/test-env"}})

## Nexus  
As you can see, we will use our private nexus registry, nexus-001:5000. So, let's set up it!  
``ssh nexus  
export https_proxy='http://user:pass@PROXY_ADDRESS:PROXY_PORT'
yum install docker -y
systemctl start docker ; systemctl enable docker
docker run --restart unless-stopped -d -e INSTALL4J_ADD_VM_PARAMS="-Xms20g -Xmx20g -XX:MaxDirectMemorySize=25g"  -p 8081:8081 -p 5000:5000 -p 5001:5001 -p 5002:5002 --name nexus3 -v /data/nexus:/nexus-data sonatype/nexus3``  
As you can see, we defined several dummy ports in range 5000:5002, keeping in mind that in nexus 1 docker repo = 1 repo http connector  
Next step: go to nexus web console (admin:admin123 default creds), and create new user (for example, docker). Also you can create new role with all permissions on docker realm.
After that, create hosted docker repo:  
- hosted;  
- http connector 5000 port;
try it:  
vim /etc/hosts
``$ip nexus-001``  
add insecure-registry option  
vim /etc/docker/daemon.json  
``{
    "insecure-registries": [
        "nexus-001:5000"
    ]
}``
Restart docker
``systemctl restart docker``  
Login
``docker login -u docker -p pass nexus-001:5000``  
If all is good, try to pull image from docker.hub via proxy, and push it to out private registry  
To accomplish that, we need to setup proxy for our docker daemon first  
vim /usr/lib/systemd/system/docker.service  
``Environment=https_proxy=`http://user:pass@PROXY_ADDRESS:PROXY_PORT``  
Restart Docker  
``systemctl daemon-reload docker; systemctl restart docker``  
Pull image and push to private registry  
``docker pull nginx; docker tag nginx nexus-001:5000/nginx; docker push nexus-001:5000/nginx``  

## Pushing right docker images in private registry  
You definetly need these images in your private registry (but I also pulled all 3.11 and 3.11.0 versions)  
Pay attention, that coreos/ images should be pulled from quay.io instead of docker.hub  
``openshift/origin-node:v3.11  
openshift/origin-pod:v3.11
openshift/origin-pod:v3.11.0
origin-template-service-broker:v3.11
origin-control-plane:v3.11
origin-console:v3.11
origin-service-catalog:v3.11
origin-web-console:v3.11
openshift/prometheus-node-exporter:v0.16.0
coreos/kube-rbac-proxy:v0.3.1
cockpit/kubernetes:latest
openshift/origin-haproxy-router:v3.11
openshift/origin-deployer:v3.11.0
coreos/prometheus-config-reloader:v0.23.2
coreos/prometheus-operator:v0.23.2
openshift/prometheus-alertmanager:v0.15.2
openshift/prometheus-node-exporter:v0.16.0
openshift/prometheus:v2.3.2
openshift/oauth-proxy:v1.1.0
coreos/configmap-reload:v0.0.1
coreos/cluster-monitoring-operator:v0.1.1
coreos/kube-state-metrics:v1.3.1
coreos/configmap-reload:v0.0.1
coreos/cluster-monitoring-operator:v0.1.1
openshift/origin-docker-registry:v3.11
grafana/grafana:5.2.1
kubernetes-helm/tiller:v2.9.0``  

Next step - you need to load proper hosts file (or setup DNS) on all(!!) nodes  


If you pushed all needed images in registry, an all nodes can successfully pull them, then we are ready to start deploy  
``screen -S deploy
ansible-playbook -i inventory/test-env playbooks/deploy_cluster.yml &&  ansible-playbook -i inventory/test-env playbooks/prerequisites.yml``  

## Post Deploy configuration  
``oadm policy add-cluster-role-to-user cluster-admin ocadmin`` - now you can login in

## Get routes  
``oc project openshift-monitoring  
oc get route``
