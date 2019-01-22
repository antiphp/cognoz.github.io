#!/bin/bash
#collect old list of images
set -x
rm -rf ins_old
readarray INS < volumes
INS_LEN=${#INS[@]}
echo $INS_LEN
echo $INS
for (( i=0; i<$INS_LEN; i++ )); do
   rbd -c /etc/ceph_old/ceph.conf -p volumes -k /etc/ceph_old/ceph.client.admin.keyring ls -l | grep ${INS[$i]}  | awk '{print $1}' >> ins_old
done

while read img; do
  rbd -c /etc/ceph_old/ceph.conf -p volumes -k /etc/ceph_old/ceph.client.admin.keyring export $img - | rbd -c /etc/ceph_new/ceph.conf -p volumes -k /etc/ceph_new/ceph.client.admin.keyring import - $img
done <ins_old
