#! /bin/sh
### BEGIN INIT INFO
# Provides:          mountpersistent
# Required-Start:    checkfs checkroot-bootclean
# Required-Stop: 
# Default-Start:     S
# Default-Stop:
# Short-Description: Mount persistent filesystem part.
# Description:
### END INIT INFO

# the mount point for persistent data (mandatory)
PERSISTENT_MNT=/mnt/persistent

# the device used for peristent data (optional, can be located in fstab)
#PERSISTENT_DEV

# use next to root partition as persistent device
#PERSISTENT_DEV_FROM_ROOT=yes

PATH=/sbin:/bin
. /lib/init/vars.sh
. /lib/init/tmpfs.sh

. /lib/lsb/init-functions
. /lib/init/mount-functions.sh
. /lib/init/swap-functions.sh

# for ntfs-3g to get correct file name encoding
if [ -r /etc/default/locale ]; then
	. /etc/default/locale
	export LANG
fi

do_start() {
	log_action_begin_msg "Mounting persistent data filesystems"
	if [ -n "$PERSISTENT_DEV_FROM_ROOT" ] ; then
		if [ ! -e /proc/cmdline ] ; then
			mount -t proc proc /proc
			umount_proc=yes
		fi
		ROOT_DEV="$(sed -n -e 's/^\(.* \|\)root=\([^ ]*\)\( .*\|\)$/\2/p' /proc/cmdline)"
		if [ -n "$umount_proc" ] ; then
			umount /proc
		fi
		if [ -z "$ROOT_DEV" ] ; then
			log_progress_msg "mountpersistent cannot obtain root device"
			log_action_end_msg 1
			exit 1
		fi
		ROOT_PART="$(echo "$ROOT_DEV" | sed -e "s/^.*\([0-9]\)$/\1/")"
		if [ -z "$ROOT_PART" ] ; then
			log_progress_msg "mountpersistent cannot obtain root partition number"
			log_action_end_msg 1
			exit 1
		fi
		PERSISTENT_DEV="${ROOT_DEV%[0-9]}$((ROOT_PART+1))"
	fi
	if [ -z "$PERSISTENT_DEV" ] ; then
		# obtain persisten device from fstab
		PERSISTENT_DEV="$(sed /etc/fstab -n -e 's#^\([^ ]*\)[ \t]\+'"$PERSISTENT_MNT"'[ \t]\+.*$#\1#p')"
	fi
	if [ -z "$PERSISTENT_DEV" ] ; then
		log_action_end_msg 3
		return 1
	fi
	if grep -q "^[^ ]* $PERSISTENT_MNT " /proc/mounts ; then
		umount -f "$PERSISTENT_MNT"
	fi
	if grep -q "^$PERSISTENT_DEV " /proc/mounts ; then
		umount -f "$PERSISTENT_DEV"
	fi
	e2fsck -p "$PERSISTENT_DEV"
	fsck_ret=$?
	if [ $fsck_ret -ge 4 ] ; then
		log_progress_msg " reformating "
		mke2fs -t ext4 -m 1 "$PERSISTENT_DEV"
	else
		if [ $fsck_ret -ne 0 ] ; then
			log_progress_msg " fixed "
		fi
	fi
	if [ -n "$PERSISTENT_DEV_FROM_ROOT" ] ; then
		mount -o rw "$PERSISTENT_DEV" "$PERSISTENT_MNT"
	else
		mount "$PERSISTENT_DEV"
	fi
	log_action_end_msg $?
}

do_stop() {
	log_action_begin_msg "Unmounting persistent data filesystem"
	if grep -q "^[^ ]* $PERSISTENT_MNT " /proc/mounts ; then
		umount "$PERSISTENT_MNT"
	fi
	log_action_end_msg $?
}

case "$1" in
  start|"")
	do_start
	;;
  restart|reload|force-reload)
	echo "Error: argument '$1' not supported" >&2
	exit 3
	;;
  stop)
	do_stop
	;;
  *)
	echo "Usage: $0 [start|stop]" >&2
	exit 3
	;;
esac

:
