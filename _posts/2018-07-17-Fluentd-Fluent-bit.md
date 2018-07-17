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
``mkdir mycharts; cp -r charts/stable/fluent-bit charts/incubator/fluentd mycharts/``  

#### Customize values  
``cd mycharts; vim fluent-bit/values.yaml``  
[fluent-bit/values.yaml]({{ "/listings/2018-07-17-Fluentd-Fluent-bit/fluent-bit-values.yaml" }})  
[fluentd/values.yaml]({{ "/listings/2018-07-17-Fluentd-Fluent-bit/fluentd-values.yaml" }})  

#### Deploy  
``helm install fluent-bit/ --name fluent-bit   
helm install fluentd/ --name fluentd``      
