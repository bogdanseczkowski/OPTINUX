#!/bin/bash
emerge-webrsync
eselect profile set "default/linux/amd64/17.0/hardened"
emerge cpuid2cpuflags
echo '
CFLAGS="-O3 -march=native -pipe"
CXXFLAGS="\${CFLAGS}"
MAKEOPTS="-j8"' >> /etc/portage/make.conf
CPU=$(cpuid2cpuflags)
out="${CPU//': '/=\"}"
echo "$out" \" >> /etc/portage/make.conf

emerge  world

emerge gentoo-sources genkernel
wget https://raw.githubusercontent.com/bogdanseczkowski/STRIP-LINUX/master/config/4.9/config.amd64
genkernel --kernel-config=config.amd64 all
rm ./config.amd64

emerge app-portage/gentoolkit grub dhcpcd

grub-install --target=i386-pc /dev/$drive &> /dev/null
grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null

rc-update add dhcpcd sshd default

echo "root:$rootpassword" | chpasswd

sed -i "s/set timeout=5/set timeout=0/" /boot/grub/grub.cfg
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8

emerge --depclean
eclean-dist --deep

exit
