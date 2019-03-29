---
layout: post  
title: Prometheus Federation for OpenShift clusters
tags: openshift linux ansible prometheus  
---


### Intro  
Mission: Deploy standalone Prometheus instances for pulling metrics from several OpenShift clusters.  

### Prerequisites  
Deployed OpenShift clusters with Prometheus cluster operators.  
2 VM for prometheus/alertmanager/executor/grafana \#8 cpu, 24ram, 400hdd  

### Deployment  
``ssh vm  
yum install -y docker``     
vim [/etc/systemd/system/docker.prometheus]({{"/listings/2019-03-26-Prometheus-federation-OpenShift/docker.prometheus"}})  
vim [/etc/systemd/system/docker.grafana]({{"/listings/2019-03-26-Prometheus-federation-OpenShift/docker.grafana"}})  

Main config for polling several OpenShift clusters (of course, endpoints should be resolvable)   
vim [/etc/prometheus/prometheus.yml]({{"/listings/2019-03-26-Prometheus-federation-OpenShift/prometheus,yml"}})

Setup rule for InstanceDown  
 vim [/etc/prometheus/rules/down.rules]({{"/listings/2019-03-26-Prometheus-federation-OpenShift/rule"}})

Alertmanager configuration  
vim [/etc/alertmanager/alertmanager.yml]({{"/listings/2019-03-26-Prometheus-federation-OpenShift/alertmanager.yml"}})

Also in case of oauth proxy in OpenShift, you need to create special user for monitoring and get it bearer_token:  
vim [user.yml]({{"/listings/2019-03-26-Prometheus-federation-OpenShift/user.yml"}})  
``kubectl create -f user.yml  
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep prom-fed | awk '{print $1}')``  
Paste output of data field of non-temporal token in prometheus.yml, where its needed.  

Restart all services, check that prometheus:9090/targets good  

That's it!  
