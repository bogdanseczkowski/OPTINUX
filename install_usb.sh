# this script is still WIP
#!/bin/bash
#create folder structure
cd /tmp/
mkdir gentoo-min/
cd gentoo-min/ 
mkdir iso/ iso-ori/
#download gentoo mnimal cd
builddate=$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/current-install-amd64-minimal/ | sed -nr 's/.*href="install-amd64-minimal-([0-9].*).iso">.*/\1/p')
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-install-amd64-minimal/install-amd64-minimal-$builddate.iso
#mount minimal cd for extraction
mount install-amd64-minimal-*.iso iso/ -o loop
cp -a iso/* iso-ori/
umount iso/
rm -rf iso/
cp -a iso-ori/ iso-new/
mkdir sqfs-old/
unsquashfs -f -d sqfs-old/ iso-ori/image.squashfs
cp -a sqfs-old/ sqfs-new/
cd sqfs-new/bin
git clone https://github.com/bogdanseczkowski/OPTINUX
cd ../..
cd iso-new/
echo \#\!/bin/bash >> create_iso.sh
echo "mkisofs -R -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -iso-level 3 -o ../livecd.iso . " >> create_iso.sh
chmod +x create_iso.sh
./create_iso.sh
cd .. 
