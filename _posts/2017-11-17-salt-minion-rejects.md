---
layout: post
title: SaltStack - master and minion relationships
tags: gluster cloud-init sed
---
### How to work out some errors between salt master and minion

#### Will be continued

If you have problems like _'AsyncAuth' object has no attribute '_finger_fail'_
in your journalctl on minion node when do:   
- Stop master and minion(s)  
- Clear out keys on master: salt-key -D  
- Clear out master key on minion(s): /etc/salt/pki/minion/minion_master.pub  
- Make sure hash_type is the same on master and minion(s): hash_type: sha256  
- Run salt-key -F master on master, copy master.pub vlaue to minion master_finger setting  
- Start master and minions  
- Accept minion key on master (salt-key -a hostname)  
