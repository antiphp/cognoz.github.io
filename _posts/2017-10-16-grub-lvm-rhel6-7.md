---
layout: post
title: Transformation of non-lvm rhel6/7 distro based running vm in lvm-based  
---
### Creating lvm-based vm from installed RHEL distro  
Our mission is to create on running vm separate /boot/ partition on /dev/vda1 and lvm partitions on /dev/vda2 (with lvroot, lvtmp, lvopt, lvvar, lvusr, lvswap)  

## Rhel6.7  
1. Create volume, attach it to vm  
`` qemu-img create -f qcow2 25G rhel6_2.qcow2  
virsh attach-disk rhel6 rhel6_2.qcow2 vdb``  
2. Start vm and logon  
``virsh start rhel6 && virt-viewer rhel6``  
3. Make partition on /dev/vdb and create fs on /dev/vdb1 ( it will be our /boot partition )  
``(echo n; echo p; echo 1; echo ; echo +200MB; echo a; echo 1; echo n;echo p; echo 2; echo ; echo ; echo t; echo 2; echo 8e; echo w) | fdisk /dev/vdb  
mkfs.ext4 -I 128 /dev/vdb1``  
4. Mount /dev/vdb1 to /mnt/ and copy all files from /boot/ to /mnt/, execute grub-install  
``echo "(hd1) /dev/vdb" >> /boot/grub/device.map  
mount /dev/vdb1 /mnt/  
rm -rf /mnt/*  
find /boot/ -xdev | cpio -pvmd /mnt  
grub-install --root-directory=/mnt/ /dev/vdb``  
5. Change kernel lines in grub config, install lvm2 and regenerate initramfs for lvm support. Copy MBR from old /dev/vda to new /dev/vdb  
``sed -i 's|.*kernel /boot/vmlinuz-2.6.32-573.el6.x86_64 ro.| kernel /boot/vmlinuz-2.6.32-573.el6.x86_64 ro root=/dev/mapper/rootvg-lvroot rd_NO_LUKS KEYBOARDTYPE=pc KEYTABLE=us LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto console=tty0 console=ttyS0,115200n8 no_timer_check rd_NO_DM rhgb quiet|' /mnt/boot/grub/grub.conf  
yum install -y lvm2  
rm -rf /var/cache/  
cd /mnt/boot/  
mv initramfs-uname -r.img initramfs-uname -r.img.bak  
dracut -f initramfs-uname -r.img uname -r  
cd; umount /mnt/  
dd if=/dev/vda of=/dev/vdb bs=446 count=1``  
6. Create lvm vggroup and lvpartitons  
``vgcreate rootvg -s 32MB /dev/vdb2  
lvcreate -L 2G -n lvroot rootvg  
lvcreate -L 4G -n lvhome rootvg  
lvcreate -L 4G -n lvtmp rootvg  
lvcreate -L 4G -n lvusr rootvg  
lvcreate -L 4G -n lvvar rootvg  
lvcreate -L 2G -n lvopt rootvg  
lvcreate -L 2G -n lvswap rootvg  
mkfs.ext4 /dev/mapper/rootvg-lvroot  
mkfs.ext4 /dev/mapper/rootvg-lvtmp  
mkfs.ext4 /dev/mapper/rootvg-lvusr  
mkfs.ext4 /dev/mapper/rootvg-lvhome  
mkfs.ext4 /dev/mapper/rootvg-lvopt  
mkfs.ext4 /dev/mapper/rootvg-lvvar  
mkswap /dev/mapper/rootvg-lvswap``  
7. Mount /dev/mapper/rootvg-lvroot to /mnt/, copy all from / and delete all unnecessary files from dirs /mnt/opt/ /mnt/boot/ /mnt/tmp/ /mnt/var/ /mnt/usr/ /mnt/home/. Change lines in fstab  
``mount /dev/mapper/rootvg-lvroot /mnt/  
rm -rf /mnt/*  
rsync -avxHAX --progress --whole-file / /mnt/  
rm -rf /mnt/boot/*  
rm -rf /mnt/var/*  
rm -rf /mnt/usr/*  
rm -rf /mnt/home/*  
rm -rf /mnt/tmp/*  
rm -rf /mnt/opt/*  
sed -i 's|.UUID.|/dev/mapper/rootvg-lvroot / ext4 errors=remount-ro 0 1|' /mnt/etc/fstab  
echo "/dev/vda1 /boot ext4 defaults 0 2" >> /mnt/etc/fstab  
echo "/dev/mapper/rootvg-lvhome /home ext4 defaults 0 2" >> /mnt/etc/fstab  
echo "/dev/mapper/rootvg-lvopt /opt ext4 defaults 0 2" >> /mnt/etc/fstab  
echo "/dev/mapper/rootvg-lvtmp /tmp ext4 defaults 0 2" >> /mnt/etc/fstab  
echo "/dev/mapper/rootvg-lvusr /usr ext4 defaults 0 2" >> /mnt/etc/fstab  
echo "/dev/mapper/rootvg-lvvar /var ext4 defaults 0 2" >> /mnt/etc/fstab  
echo "/dev/mapper/rootvg-lvswap none swap sw 0 0" >> /mnt/etc/fstab  
umount /mnt/``  
8. Mount and repeate step 7 on others partitions  
``mount /dev/mapper/rootvg-lvtmp /mnt/  
rm -rf /mnt/*  
rsync -avxHAX --progress --whole-file /tmp/ /mnt/  
umount /mnt/  
mount /dev/mapper/rootvg-lvusr /mnt/  
rm -rf /mnt/*  
rsync -avxHAX --progress --whole-file /usr/ /mnt/  
umount /mnt/  
mount /dev/mapper/rootvg-lvvar /mnt/  
rm -rf /mnt/*  
rsync -avxHAX --progress --whole-file /var/ /mnt/  
umount /mnt/  
mount /dev/mapper/rootvg-lvhome /mnt/  
rm -rf /mnt/*  
rsync -avxHAX --progress --whole-file /home/ /mnt/  
umount /mnt/  
mount /dev/mapper/rootvg-lvopt /mnt/  
rm -rf /mnt/*  
rsync -avxHAX --progress --whole-file /opt/ /mnt/  
umount /mnt/  
shutdown -h now``  
9. Profit  

##RHEL7  
0. Almost identically, but  
``grub2-install --root-directory=/mnt/ /dev/vdb  
vdb1id=lsblk -f | grep vdb1 | awk '{print $3}'  
sed -i "s/.search --no-floppy --fs-uuid --set=root --hint='hd0,msdos1'./ search --no-floppy --fs-uuid --set=root --hint='hd0,msdos1' $vdb1id/" /mnt/boot/grub2/grub.cfg  
sed -i "s|.linux16 /boot/vmlinuz-3.10.0-327.10.1.el7.x86_64 root=UUID.| linux16 /boot/vmlinuz-3.10.0-327.10.1.el7.x86_64 root=/dev/mapper/rootvg-lvroot ro console=tty0 console=ttyS0,115200n8 no_timer_check net.ifnames=0 crashkernel=auto rd.lvm.lv=rootvg/lvroot rd.lvm.lv=rootvg/lvswap rd.lvm.lv=rootvg/lvtmp rd.lvm.lv=rootvg/lvusr rd.lvm.lv=rootvg/lvvar rd.lvm.lv=rootvg/lvopt rd.lvm.lv=rootvg/lvhome LANG=en_US.UTF-8|"  
/mnt/boot/grub2/grub.cfg``  
