---
layout: post
title: Gluster - Changing peer's hostnames
tags: gluster cloud-init sed
---
### Changing of gluster peers hostnames

#### Simple tutorial - how to change peer's hostnames in gluster cluster without destroing anything  

_Run on all gluster nodes_  
1. Stop glusterd processes  
``sudo systemctl stop glusterd``  
2. Change hostnames  
``sudo hostnamectl set-hostname $hostname``  
3. Remove cloud-init hostname* modules from cloud_init_modules list if you are using cloud vm's  
``sudo vi /etc/cloud-init/cloud.cfg``  
4. Change hosts file  
``sudo vi /etc/hosts``  
5. Recursively change all old hostnames with new one's in /var/lib/glusterd directory  
``sudo find ./ -type f -exec sed -i 's/$OLD/$NEW/g' {} \;``  
6. Move brick folders to new destination based on new hostnames  
``##EXAMPLE  
sudo cd /var/lib/glusted/vols/gluster_shared_storage/  
sudo mv test-nfs-rk-2\:-var-lib-glusterd-ss_brick gluster-nfs-1\:-var-lib-glusterd-ss_brick``  
7. Start glusterd process  
``sudo systemctl start glusterd``
