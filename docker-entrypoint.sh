#!/bin/dumb-init /bin/sh
set -e

umount_nfs () {
  echo "Unmounting nfs..."
  umount "$MOUNTPOINT"
  exit
}

mkdir -p "$MOUNTPOINT"
rpc.statd -F -p 32765 -o 32766 &
rpcbind -f &

if [ ! -z $SERVER ]; then
  echo "Mounting nfs..."
  mount -t "$FSTYPE" -o "$MOUNT_OPTIONS" "$SERVER:$SHARE" "$MOUNTPOINT"
  mount | grep nfs
  trap umount_nfs SIGHUP SIGINT SIGTERM
fi

while true; do sleep 1000; done
