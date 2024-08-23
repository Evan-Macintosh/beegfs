#!/bin/bash
##########
# install what you need
##########
echo “deb http://ftp.de.debian.org/debian bookworm main contrib” >> /etc/apt/sources.list
echo "https://www.beegfs.io/release/beegfs_7.4.4/dists/beegfs-deb12.list" >> /etc/apt/sources.list.d/beegfs.list
wget -q https://www.beegfs.io/release/beegfs_7.4.4/gpg/GPG-KEY-beegfs -O- | apt-key add -
apt update
apt install multipath-tools device-mapper* zfsutils-linux xfsprogs

##########
# set up multipath devices
##########
systemctl disable multipathd.service
# make sure to ignore your localdata and other non-multipath'd devices
for INDEX in {b..z}; do multipath -a /dev/sd$INDEX; done
for INDEX in {a..w}; do multipath -a /dev/sda$INDEX; done
modprobe dm_multipath
systemctl enable multipathd.service

##########
# metadata tunings; https://doc.beegfs.io/latest/advanced_topics/metadata_tuning.html
##########
declare -a METADATA_DISKS=(sdX sdY)
NUM_DISKS=${METADATA_DISKS[@]}
for (( INDEX=0 ; ${INDEX} < ${NUM_DISKS}; INDEX++ )); do
	TARGET_DISK=${METADATA_DISKS[$INDEX]}
	echo deadline > /sys/block/$TARGET_DISK/queue/scheduler
	echo 128 > /sys/block/$TARGET_DISK/queue/nr_requests
 	echo 128 > /sys/block/$TARGET_DISK/queue/read_ahead_kb
 	echo 256 > /sys/block/$TARGET_DISK/queue/max_sectors_kb
done

##########
# data tunings; https://doc.beegfs.io/latest/advanced_topics/storage_tuning.html
##########
for INDEX in `seq 0 1 23`; do 
	echo deadline > /sys/block/dm-$INDEX/queue/scheduler
	echo 4096 > /sys/block/dm-$INDEX/queue/nr_requests
	echo 4096 > /sys/block/dm-$INDEX/queue/read_ahead_kb
	echo 256 > /sys/block/dm-$INDEX/queue/max_sectors_kb
done
echo 4194304 > /sys/module/zfs/parameters/zfs_maxrecordsize
echo 1310720 > /sys/module/zfs/parameters/zfs_read_chunk_size
echo 0 > /sys/module/zfs/parameters/zfs_prefetch_disable


##########
# meta/data tunings
##########
echo deadline > /sys/module/zfs/parameters/zfs_vdev_scheduler
echo 262144 > /sys/module/zfs/parameterse/zfs_vdev_aggregation_limit
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 20 > /proc/sys/vm/dirty_ratio
echo 50 > /proc/sys/vm/vfs_cache_pressure
echo 262144 > /proc/sys/vm/min_free_kbytes
echo 1 > /proc/sys/vm/zone_reclaim_mode
echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag

##########
# create metadata device(s)
##########
mkdir -p /mnt/zfs/zpool-m0
ZFS_OPTIONS="-o ashift=12 -O atime=off -O canmount=off -O compression=lz4"
m0_DEVS=""
zpool create $ZFS_OPTIONS zpool-m0 mirror $m0_DEVS
zpool set mountpoint=/mnt/zfs/zpool-m0 zpool-m0
zfs create -o mountpoint=/mnt/zfs/zvol-m0 zpool-m0/data
mkfs.ext4 -i 2048 -I 512 -J size=400 -Odir_index,filetype /mnt/zfs/zvol-m0 # BeeGFS tunings for filesystem(s) on metadata device(s)

##########
# create data device(s)
##########
mkdir -p /mnt/zfs/{zpool-d0,zpool-d1}
export d0_MPATH_DEVS=""
export d1_MPATH_DEVS=""
zpool create $ZFS_OPTIONS zpool-d0 raidz2 $d0_MPATH_DEVS
zpool create $ZFS_OPTIONS zpool-d1 raidz2 $d1_MPATH_DEVS
zpool set mountpoint=/mnt/zfs/zpool-d0 zpool-d0
zpool set mountpoint=/mnt/zfs/zpool-d1 zpool-d1
zfs create -o mountpoint=/mnt/zfs/zvol-d0 zpool-d0/data
zfs create -o mountpoint=/mnt/zfs/zvol-d1 zpool-d1/data
mkfs -t xfs -f /mnt/zfs/zvol-d0
mkfs -t xfs -f /mnt/zfs/zvol-d1

##########
# create BeeGFS filesystem
##########
BEEGFS_MASTER=lcs-s1-hsn0
apt install beegfs-mgmtd beegfs-meta beegfs-storage beegfs-helperd beegfs-utils
/opt/beegfs/sbin/beegfs-setup-mgmtd -p /data/beegfs/beegfs_mgmtd
/opt/beegfs/sbin/beegfs-setup-meta -p /mnt/zfs/zvol-m0 -s 1 -m $BEEGFS_MASTER # look into syntax for adding other nodes as metadata servers
/opt/beegfs/sbin/beegfs-setup-storage -p /mnt/zfs/zvol-d0 -s 1 -i 101 -m $BEEGFS_MASTER
/opt/beegfs/sbin/beegfs-setup-storage -p /mnt/zfs/zvol-d1 -s 1 -i 102 -m $BEEGFS_MASTER # repeat for all volumes
