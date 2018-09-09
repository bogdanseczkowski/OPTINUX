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
mkdir gentoo

if [[ $partitioning = "a" ]]; then
    dd if=/dev/zero of=/dev/$drive bs=512 count=1
    echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/$drive
    mkfs.ext4 -F /dev/$partition
fi
mount /dev/$partition gentoo

cd gentoo

fallocate -l 4G ./swapfile
chmod 600 ./swapfile
mkswap ./swapfile
swapon ./swapfile

builddate=$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/ | sed -nr 's/.*href="stage3-amd64-([0-9].*).tar.xz">.*/\1/p')
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-$builddate.tar.xz
tar xpf ../stage3-* --xattrs-include='*.*' --numeric-owner
rm -f stage3*
echo '/swapfile none swap sw 0 0' | tee -a ./etc/fstab

cp /etc/resolv.conf etc
mount --types proc /proc ./gentoo/proc
mount --rbind /sys ./gentoo/sys
mount --make-rslave ./gentoo/sys
mount --rbind /dev ./gentoo/dev
mount --make-rslave ./gentoo/dev
#mount -t /proc none proc
#mount --rbind /dev dev
#mount --rbind /sys sys
cp ../chroot.sh ./chroot.sh
chmod +x ./chroot.sh
chroot . /chroot.sh

reboot
