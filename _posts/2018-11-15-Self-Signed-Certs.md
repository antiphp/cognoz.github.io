---
layout: post  
title: Creation and appliance of self-signed certs in kubernetes with chrome / firefox
tags: linux ssl
---

#### How to create CA, sign with it new certs and accept CA in chrome/firefox  

Centos 7 machine  
Create [this]({{"/listings/2018-11-15-Self-Signed-Certs/ssl_req.sh"}}) sh script, change your domainnames in cycle, run:
```
vim ssl_req.sh
chmod +x req.sh
./req.sh
```
In Google Chrome / Firefox go to  Settings/Advanced, find Certificates block, import ca.crt in trusted root certificates, restart browser.  
