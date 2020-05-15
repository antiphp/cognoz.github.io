#Mitaka MOS
parted /dev/$DEV mkpart primary 238 $SIZE
parted /dev/$DEV set 1 bios_grub
ceph-deploy --ceph-conf /root/ceph.conf osd prepare localhost:${DEV}3
ceph-deploy --ceph-conf /root/ceph.conf osd activate localhost:${DEV}3
sgdisk --typecode=3:4fbd7e29-9d25-41b8-afd0-062c0ceff05d -- /dev/$DEV
#ceph auth add osd.30 mon 'allow profile osd' osd 'allow *'
#ceph osd crush add 30 1.09 host=skl-os-ceph02.HDD (30 - osd-id, 1.09 - weight)
