rpi-utils
=========

Utilities and Configurations for Raspberry Pi GNU/Linux
-------------------------------------------------------

This is set of utilities which help to run and mantain
GNU/Linux for Raspberry Pi platform. But many of them are
of general embedded syetems use or even usable for
desktop and server systems.

init-overlay - Overlay Setup for Read-Only Root FS
--------------------------------------------------
This is script and configuration tool which allows to switch
minimal or full-featured Linux distribution to mode where
all root filesystem changes are temporal/hold only in system RAM.
This mode is selected by addition init=/sbin/init-overlay
parameter to Linux kernel command line. Solution finds and uses
available layered  filesystem support (aufs, overlay, unionfs).

The documentation can be found in [init-overlay.txt](init-overlay/usr/share/doc/init-overlay/init-overlay.txt)
file which is intended to be copyed with scripts to the
target root filesystem. The install and uninstall overlayctl
commands are Raspberry Pi specific for now but rest is portable
to any other system.

Some more information can be found in [InstallFest 2015 presentation slides](http://cmp.felk.cvut.cz/~pisa/installfest/rpi_overlay_and_rt.pdf).

The Raspberry Pi kernel including Aufs patches and configured to
build Aufs and overlayfs support can be cloned from [linux-rpi](https://github.com/ppisa/linux-rpi)
repository.

mount-img-parts - Script to Access and Mount Partitions on Disk/SD-card image
-----------------------------------------------------------------------------
The cript can setup loopback device for each partition, enables to mount
image partitions etc. It requires administrator priviledges and creates
local directory with devices and mountpoints according to found
DOS MBR style partition table.

For more information consult [mount-img-parts](scripts/mount-img-parts)
script dierctly.

u-boot-setup - Raspberry Pi U-Boot Build Setup and EXTLINUX Config
------------------------------------------------------------------
Stephen Warren's U-Boot version is cloned, configured and built
by [build-u-boot](u-boot-setup/build-u-boot). Example EXTLINUX
config to select local boot from SD-card or NFS root is provided as well.

