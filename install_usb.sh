# this script is still WIP but it should work
# todo automatic installer execution
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
cd sqfs-new/opt
git clone https://github.com/bogdanseczkowski/OPTINUX
cd ../..
chmod +x /opt/OPTINUX/install.sh
chmod +x /opt/OPTINUX/chroot.sh
echo "/opt/OPTINUX/install.sh" >> /etc/conf.d/local.start
rm iso-new/image.squashfs
mksquashfs sqfs-new/ iso-new/image.squashfs
echo \#\!/bin/bash >> create_iso.sh
echo "cd iso-new/" >> create_iso.sh
echo "mkisofs -R -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -iso-level 3 -o ../livecd.iso . " >> create_iso.sh
chmod +x create_iso.sh
./create_iso.sh
cd .. 
