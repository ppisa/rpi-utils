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

PERSISTENT_MNT=/mnt/persistent

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
	PERSISTENT_DEV="$(sed /etc/fstab -n -e 's#^\([^ ]*\)[ \t]\+'"$PERSISTENT_MNT"'[ \t]\+.*$#\1#p')"
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
	mount "$PERSISTENT_DEV"
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
	echo "Usage: mountall.sh [start|stop]" >&2
	exit 3
	;;
esac

:
