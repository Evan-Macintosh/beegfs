#!/bin/bash
##########
# create BeeGFS filesystem
##########
BEEGFS_MASTER=lcs-s1-hsn0
beegfs-setup-mgmtd -p /data/beegfs/
beegfs-setup-meta -p /mnt/beegfs-meta -m $BEEGFS_MASTER
beegfs-setup-storage -p /mnt/beegfs-data0 -m $BEEGFS_MASTER
beegfs-setup-storage -p /mnt/beegfs-data1 -m $BEEGFS_MASTER
