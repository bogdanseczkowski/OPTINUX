The OPTINUX project aims to create Linux distro that is well optimized and by that blazing fast. To achieve that install script adjust GCC flags for detected CPU and compiles Gentoo and Linux kernel from source. STRIP-LINUX install script is based on Clover OS scripts (https://cloveros.ga/). Currently, it uses Liquorix kernel config files.
To install OPTINUX
1. Download and burn Gentoo minimal live
2. Boot  Gentoo minimal live on your PC
3. Download and run install.sh from STRIP-LINUX Github.
4. Reboot

To Do:
1.Automatic MAKE OPTS
2.automatic cflags generation (instead of -mtune=native)
