#!/bin/dumb-init /bin/sh
set -e

umount_nfs () {
  echo "Unmounting nfs..."
  umount "$MOUNTPOINT"
  exit
}

echo "Mounting nfs..."

mkdir -p "$MOUNTPOINT"
rpc.statd -F -p 32765 -o 32766 &
rpcbind -f &
mount -t "$FSTYPE" -o "$MOUNT_OPTIONS" "$SERVER:$SHARE" "$MOUNTPOINT"
mount | grep nfs

trap umount_nfs SIGHUP SIGINT SIGTERM

while true; do sleep 1000; done
