#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

while :; do
    echo
    read -erp "Automatic partitioning (a) or manual partitioning? (m) [a/m] " -n 1 partitioning
    if [[ $partitioning = "a" ]]; then
        read -erp "Enter drive for Strip Linux installation: " -i "/dev/sda" drive
        partition=${drive}1
    elif [[ $partitioning = "m" ]]; then
        read -erp "Enter partition for Strip Linux installation: " -i "/dev/sda1" partition
        if [[ $partition == /dev/map* ]]; then
            read -erp "Enter drive that contains install partition: " -i "/dev/sda" drive
        else
            drive=${partition%"${partition##*[!0-9]}"}
        fi
    else
        echo "Invalid option"
    fi
    drive=${drive#*/dev/}
    partition=${partition#*/dev/}
    read -erp "Partitioning: $partitioning
Drive: /dev/$drive
Partition: /dev/$partition
Is this correct? [y/n] " -n 1 yn
    if [[ $yn == "y" ]]; then
        break
    fi
done

while :; do
    echo
    read -erp "Enter preferred root password " rootpassword
    if [[ $yn == "y" ]]; then
        break
    fi
done

mkdir gentoo

if [[ $partitioning = "a" ]]; then
    echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/$drive
    mkfs.ext4 -F /dev/$partition
fi
tune2fs -O ^metadata_csum /dev/$partition
mount /dev/$partition gentoo

cd gentoo

fallocate -l 4G ./swapfile
chmod 600 ./swapfile
mkswap ./swapfile
swapon ./swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a ./etc/fstab

builddate=$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/ | sed -nr 's/.*href="stage3-amd64-([0-9].*).tar.xz">.*/\1/p')
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-$builddate.tar.xz
tar xpf stage3-* --xattrs-include='*.*' --numeric-owner
rm -f stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat << EOF | chroot .

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
wget http://liquorix.net/sources/4.15/config.amd64
genkernel --kernel-config=config.amd64 all
rm ./config.amd64

emerge grub dhcpcd

grub-install --target=i386-pc /dev/$drive &> /dev/null
grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null

rc-update add dhcpcd default

echo "root:$rootpassword" | chpasswd

sed -i "s/set timeout=5/set timeout=0/" /boot/grub/grub.cfg
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8

emerge --depclean
rm -Rf /usr/portage/packages/*

exit

EOF

reboot
