---
layout: post
title: Kubespray  
tags: kubernetes kubespray deploy
---

### Tips for kubespray deployment (7 nodes)  

0. On all nodes  
``apt install python-minimal  
echo '127.0.0.1 hostname' >> /etc/hosts``  
1. On kubespray machine  
``apt-get update   
apt-get install software-properties-common     
apt-add-repository ppa:ansible/ansible     
apt-get update   
apt-get install ansible    
apt install  python-netaddr     
git clone https://github.com/kubernetes-incubator/kubespray.git ``   
2. ``cd kubespray; cp -rfp inventory/sample inventory/mycluster``    
3. ``declare -a IPS=(IP1_master IP2_master2 IP3_compute1 IP4_compute2 IP5_etcd1 IP6_etcd2 IP7_etcd3)``  
4. CONFIG_FILE=inventory/mycluster/hosts.ini python3 contrib/inventory_builder/inventory.py ${IPS[@]}  
5. Reconfigure inventory/mycluster/hosts.ini file if needed  
6. configure inventory/mycluster/group_vars/* if needed  
[all.yaml]({{ "/listings/2018-03-22-kubespray/all.yaml" }})
[k8s-cluster.yaml]({{ "/listings/2018-03-22-kubespray/k8s-cluster.yaml" }})
Also, I recommend before deployment to look on these vars:  
cat inventory/mycluster/group_vars/k8s-cluster.yml   
    docker_dns_servers_strict: false  
cat roles/kubernetes/node/defaults/main.yml  
    kube_cadvisor_port: 4194  
    kubelet_bind_address: 0.0.0.0   
If you are planning to use Calioco on virtual environment with host mtu < 1500 do not forget to correct this one too:  
cat roles/network_plugin/calico/defaults/main.yml  
   calico_mtu: 1400  
7. ``ansible-playbook -i inventory/mycluster/hosts.ini cluster.yml``  
8. If you are experiencing timeouts, you should check that in /etc/hosts on every host exists correct localhost line. It happens cause sudo cant resolve localhost.   
``for i in IP1 IP2 IP3 IP4 IP5 IP6 IP7; do ssh -x $i 'echo 127.0.0.1 hostname >> /etc/hosts'``    
9. If you are planning to use nfs pv, then you should to install nfs-common package on all computes/masters  
``for i in IP1 IP2 IP3 IP4; do ssh -x $i 'apt update; apt -y install nfs-common'``    
10. After deploy you can find your credentials in inventory/mycluster/credentials/kube_user, and kube/config on all masters  
11. If you want to change stuff in kubelets after deploying, go to /etc/kubernetes/kubelet.env and restart kubelet service   
If you want to use prometheus / grafana do stuff that mentioned in Cheats  
