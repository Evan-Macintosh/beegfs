#!/bin/bash
##########
# create BeeGFS filesystem
##########
BEEGFS_MASTER=lcs-s1-hsn0
beegfs-setup-mgmtd -p /data/beegfs/
beegfs-setup-meta -p /mnt/beegfs-meta -s 100 -m $BEEGFS_MASTER
beegfs-setup-storage -p /mnt/beegfs-data0 -s 200 -m $BEEGFS_MASTER
beegfs-setup-storage -p /mnt/beegfs-data1 -s 201 -m $BEEGFS_MASTER
