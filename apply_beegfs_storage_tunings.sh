#!/bin/bash
# apply storage tunings
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 20 > /proc/sys/vm/dirty_ratio
echo 50 > /proc/sys/vm/vfs_cache_pressure
echo 262144 > /proc/sys/vm/min_free_kbytes
echo 1 > /proc/sys/vm/zone_reclaim_mode

echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag

# apply ZFS tunings before creating any pools
echo 4194304 > /sys/module/zfs/parameters/zfs_max_recordsize
echo deadline > /sys/module/zfs/parameters/zfs_vdev_scheduler
echo 1310720 > /sys/module/zfs/parameters/zfs_read_chunk_size
echo 0 > /sys/module/zfs/parameters/zfs_prefetch_disable
echo 262144 > /sys/module/zfs/parameters/zfs_vdev_aggregation_limit

# apply tunings to multipath devices
for DEVICE in $(ls /dev/ | grep dm-. | awk '{printf "%s ",$1}'); do
	echo deadline > /sys/block/$DEVICE/queue/scheduler
	echo 4096 > /sys/block/$DEVICE/queue/nr_requests # system file full. must manually edit; it doesnt like that. Why?
	echo 4096 > /sys/block/$DEVICE/queue/read_ahead_kb
	echo 256 > /sys/block/$DEVICE/queue/max_sectors_kb
done