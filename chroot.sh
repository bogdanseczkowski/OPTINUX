#!/bin/bash
emerge-webrsync
eselect profile set "default/linux/amd64/17.0/hardened"
emerge cpuid2cpuflags
np=$(nproc)
enp=`expr $np + 1`
echo '
CFLAGS="-O3 -march=native -pipe"
CXXFLAGS="${CFLAGS}"
EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y"
MAKEOPTS="-j'$enp\" >> /etc/portage/make.conf
CPU=$(cpuid2cpuflags)
out="${CPU//': '/=\"}"
echo "$out" \" >> /etc/portage/make.conf

emerge  world

emerge gentoo-sources genkernel
echo -e "y\n" | etc-update --automode -3
emerge gentoo-sources genkernel curl
emerge app-arch/lz4
wget https://raw.githubusercontent.com/bogdanseczkowski/STRIP-LINUX/master/config/4.14/config.amd64
sed -i "s/CONFIG_EXT4_FS=m/CONFIG_EXT4_FS=y/g" config.amd64
genkernel --kernel-config=config.amd64 all
rm ./config.amd64

emerge  --newuse --deep sys-boot/grub:2
emerge app-portage/gentoolkit dhcpcd 

grub-install --target=i386-pc /dev/$drive &> /dev/null
grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null

rc-update add dhcpcd default
rc-update add sshd default

echo "root:toor" | chpasswd

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8

emerge --depclean
eclean-dist --deep

exit
