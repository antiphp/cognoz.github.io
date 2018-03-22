---
layout: post
title: Kubespray  
tags: kubernetes kubespray deploy
---

### Tips for kubespray deployment (7 nodes)  

1. ``cd /opt; git clone https://github.com/kubernetes-incubator/kubespray.git``    
2. ``cd kubespray; cp -rfp inventory/sample inventory/mycluster``    
3. ``declare -a IPS=(IP1_master IP2_master2 IP3_compute1 IP4_compute2 IP5_etcd1 IP6_etcd2 IP7_etcd3)``  
4. CONFIG_FILE=inventory/mycluster/hosts.ini python3 contrib/inventory_builder/inventory.py ${IPS[@]}  
5. Reconfigure inventory/mycluster/hosts.ini file if needed  
6. configure inventory/mycluster/group_vars/* if needed  
[all.yaml]({{ "/listings/2018-03-22-kubespray/all.yaml" }})
[k8s-cluster.yaml]({{ "/listings/2018-03-22-kubespray/k8s-cluster.yaml" }})
7. ``ansible-playbook -i inventory/mycluster/hosts.ini cluster.yml``  
8. If you are experiencing timeouts, you should check that in /etc/hosts on every host exists correct localhost line. It happens cause sudo cant resolve localhost.   
``for i in IP1 IP2 IP3 IP4 IP5 IP6 IP7; do ssh -x $i 'echo 127.0.0.1 hostname >> /etc/hosts'``    
9. If you are planning to use nfs pv, then you should to install nfs-common package on all computes/masters  
``for i in IP1 IP2 IP3 IP4; do ssh -x $i 'apt update; apt -y install nfs-common'``    
10. After deploy you can find your credentials in inventory/mycluster/credentials/kube_user, and kube/config on all masters  
