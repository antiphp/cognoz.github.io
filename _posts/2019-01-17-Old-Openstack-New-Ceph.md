---
layout: post  
title: Integration of old OpenStack(Kilo) with new Ceph cluster (Luminous)  
tags: linux ceph openstack
---


### Intro  
We had one customer who wanted to deploy new Ceph cluster on two nodes, integrate them in Old Openstack Mirantis 7.0 environment and start migration process (instances, volumes, images, etc) to it.  
At first glance this task seems pretty simple - just create new cinder backend, copy new ceph.conf/keyrings and begin migration on holidays/weekend.  
But in reality, old openstack services such as glance,nova,cinder dont work with new rbd/rados in Ceph Luminous. But we found a way! So let's start.

### The problem  
Standart RBD cinder driver (cinder/volume/drivers/..) use Rados and Rbd libraries. If they outdated (as it is in our example) when driver will not be initialized (you can check it in cinder-volume log). So we need to find new libs, copy them on node, point cinder-volume service to use them, and restart service.   
### Libs  
First of all, you should find several rbd/rados libraries for openstack services. I achieved it with spare node, there I installed ceph-luminous packages. If you are using MOS7, you can download them from here:   
[libs.tar 22MB]({{"/listings/2019-01-17-Old-Openstack-New-Ceph/libs.tar.bzip2"}})  
.. class:: spoiler
list of files
``tree /opt/cool_libs/
/opt/cool_libs/
├── ceph
│   ├── compressor
│   │   ├── libceph_snappy.so
│   │   ├── libceph_snappy.so.2
│   │   ├── libceph_snappy.so.2.0.0
│   │   ├── libceph_zlib.so
│   │   ├── libceph_zlib.so.2
│   │   ├── libceph_zlib.so.2.0.0
│   │   ├── libceph_zstd.so
│   │   ├── libceph_zstd.so.2
│   │   └── libceph_zstd.so.2.0.0
│   ├── crypto
│   │   ├── libceph_crypto_isal.so
│   │   ├── libceph_crypto_isal.so.1
│   │   └── libceph_crypto_isal.so.1.0.0
│   ├── libceph-common.so
│   └── libceph-common.so.0
├── libceph-common.so
├── libceph-common.so.0
├── libcephfs.so.2
├── libcephfs.so.2.0.0
├── librados.so.2
├── librados.so.2.0.0
├── libradosstriper.so.1
├── libradosstriper.so.1.0.0
├── librados_tp.so.2
├── librados_tp.so.2.0.0
├── librbd.so.1
├── librbd.so.1.12.0
├── librbd_tp.so.1
├── librbd_tp.so.1.0.0
├── librgw.so.2
├── librgw.so.2.0.0
└── libstdc++.so.6``

 Copy them to target node (controller for glance and cinder services / compute for libvirtd), unarchive, chmod 777 -R (just to be sure that there will be no permission denied issues).
 Furthemore, we need to point services on this libraries. For example, for cinder-volume do this:  
 vim /etc/default/cinder-volume  
 ``export LD_LIBRARY_PATH="/opt/cool_libs/"``  
 Do it for cinder-volume / glance-api on controller node and for nova-compute / libvirtd on compute node.  

 Next step: Copy New Ceph keyrings and conf to target nodes, make link. permissions    
 ``scp -r ceph IP:/etc/ceph_new  
 ssh IP  
 mv /etc/ceph/ /etc/ceph_old  (OPenstack services dont have keyring option, so we are doing links)  
 ln -s /etc/ceph_new /etc/ceph/  
 cd /etc/ceph  
 chown cinder:cinder *volumes*  *backups*
 chown glance:glance *images*
 chown nova:nova *compute*``  

Configure backend on ONE! node with cinder-volume:  
vim /etc/cinder/cinder.conf  
``[DEFAULT]
enabled_backends = ceph-2  
....

[ceph-2]
volume_backend_name=ceph-2
volume_driver=cinder.volume.drivers.rbd.RBDDriver
rbd_user=volumes
rbd_ceph_conf=/etc/ceph/ceph.conf
rbd_pool=volumes
rbd_secret_uuid=WE_CREATE_IT_LATER  
host=rbd:volumes``  

Also, do not forget about types  
``cinder --os-username admin --os-tenant-name admin type-create lvm
cinder --os-username admin --os-tenant-name admin type-key lvm set volume_backend_name=LVM_iSCSI
cinder --os-username admin --os-tenant-name admin extra-specs-list (just to check the settings are there)``  

If you have create the same pools on new ceph cluster that on old one (and users), then you didn't need to change glace-api conf.  
Commands to create pools / users  
``ceph osd pool create volumes 128 replicated replicated_rule  
ceph osd pool create images 128 replicated replicated_rule
ceph osd pool create compute 128 replicated replicated_rule
ceph osd pool create backups 128 replicated replicated_rule
# if you have old users just do ceph auth del client.user ``  
BE EXCEPTIONALLY CAREFULL WITH KEYS - Ceph changed its format  

On compute host, we need to generate new secret for ceph cluster:  
Using instructions from here http://docs.ceph.com/docs/giant/rbd/libvirt/ do:  
``cat > secret.xml <<EOF
<secret ephemeral='no' private='no'>
        <usage type='ceph'>
                <name>client.libvirt secret</name>
        </usage>
</secret>
EOF
virsh secret-define --file secret.xml  # do it on all compute hosts
Write down somewhere the secret UUID from step above``  

Copy compute.keyring from new cluster to compute node, set value  
``scp client.compute.key compute-IP:
ssh compute-IP  
virsh secret-set-value --secret {uuid of secret} --base64 $(cat client.compute.key)``  

Now you can change rbd_secret_uuid in /etc/nova/nova.conf.  
Example libvirt guest xml witch secret uuid:  
[xml]({{"/listings/2019-01-17-Old-Openstack-New-Ceph/example.xml"}})  
``virsh define example.xml``  

Now point to library directory for nova-compute / libvirtd:  
vim /etc/default/libvirtd /nova-compute  
 ``export LD_LIBRARY_PATH="/opt/cool_libs/"``  
restart services,  and pray  
on compute
``service nova-compute restart``
on controller
``for i in glance-api cinder-volume; do service $i restart; done``
Check logs:  
less /var/log/cinder/cinder-volume.log (shift+F to tail)  


<host name='10.220.109.15' port='6789'/>
<host name='10.220.109.16' port='6789'/>
<host name='10.220.109.17' port='6789'/>
