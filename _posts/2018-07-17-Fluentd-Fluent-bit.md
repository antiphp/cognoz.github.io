---
layout: post  
title: Fluentd Fluent-bit Helm deployment with integration to external ES    
tags: kubernetes helm fluentd fluent-bit log  
---

### Integration of fluent-bit fluentd  helm charts with external elasticsearch  

Test environment:  
- Several k8s nodes  
- K8S version: 1.10.4  #### deployed via kubespray (tiller included)  
- RBAC enabled  
- Internet Access  

#### Clone default charts from github  
``git clone https://github.com/kubernetes/charts.git``   

#### Copy charts  
``mkdir mycharts; cp -r charts/stable/fluentd-elasticsearch mycharts/``  

#### Customize values  
``cd mycharts; vim fluentd-elasticsearch/values.yaml``  
[fluentd-elasticsearch/values.yaml]({{ "/listings/2018-07-17-Fluentd-Fluent-bit/fluentd-values.yaml" }})  

#### Deploy  
``kubectl create ns logging  
helm install --name fluentd-elasticsearch --namespace logging fluentd-elasticsearch/``    
