---
layout: post
title: Paswordless SSH forwarding through several hosts  
tags: linux ssh auth
---
### How to configure paswordless ssh with ssh-agent

1. Obtain your private ssh key (key format doesn't matter)  
Let's assume we have a key "key.pem"  

2. Copy pubkey to the proxy server and the target one  
``for i in 1 2; do ssh-copy-id ubuntu@10.10.10.1$i; done``    

3. Start locally ssh-agent, export connection details in shell  
``eval${ssh-agent -s}``  

4. Add key to your current ssh session  
``ssh-add -k key.pem; ssh-add -l``  

5. SSH to the Proxy (you don't need to specify key, after step 4), configure forwarding if necessary  
`` ssh ubuntu@proxy``  
vim /etc/ssh/ssh_config  
``Host $host_ip
  ForwardAgent yes``  
6. Voila! Now you can ssh to Proxy server + 1 another server (A) + 1 (B).  
If you only want to passthrough 1 proxy server you don't need to configure  _ForwardAgent_ option   
