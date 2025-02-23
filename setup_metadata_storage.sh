#!/bin/bash
##########
### NOTE: THIS SCRIPT HAS BEEN DEPRECATED IN FAVOR OF create_zfs_{metadata,storage}.sh SCRIPTS
##########

##########
### misc. conventions
##########
# things related to pools (name, mount point, etc) will use '_' to space out names
# things related to zvols will use '-' 
# eg: the metadata pool is called meta_pool0 and is mounted at /mnt/meta_pool0. It has a 200GB zvol called meta_zvol 
# which, after having an ext4 partition created, is mounted at /mnt/beegfs-meta

##########
### setup
##########
pool_options="-o ashift=12 -O atime=off -O compression=lz4"
meta_pool_devices="/dev/dm-24 /dev/dm-25"	# 
data_pool_devices="/dev/dm-0 /dev/dm-1 /dev/dm-2 /dev/dm-3 /dev/dm-4 /dev/dm-5 /dev/dm-6 /dev/dm-7 /dev/dm-8 /dev/dm-9 /dev/dm-10 /dev/dm-11 /dev/dm-12 /dev/dm-13 /dev/dm-14 /dev/dm-15 /dev/dm-16 /dev/dm-17 /dev/dm-18 /dev/dm-19 /dev/dm-20 /dev/dm-21 /dev/dm-22 /dev/dm-23"

##########
### create the metadata pool and zvol
##########
# mdadm --create beegfs-metadata -n 2 -l 1 -N bgfs-meta $meta_pool0_devices # this sucks, why did i do this?
# mkfs.ext4 -i 2048 -I 512 -J size=400 -Odir_index,filetype /dev/md127
zpool create $pool_options -O mountpoint=/mnt/meta_pool meta_pool mirror $meta_pool_devices
zfs create -V 174.625GB meta_pool/meta_zvol
mkfs.ext4 -i 2048 -I 512 -J size=400 -Odir_index,filetype /dev/zvol/meta_pool/meta_zvol
mkdir -p /mnt/beegfs-meta
mount /dev/zvol/meta_pool/meta_zvol /mnt/beegfs-meta
echo "/dev/zvol/meta_pool/meta_zvol /mnt/beegfs-meta ext4 defaults 0 0" >> /etc/fstab

##########
### create the data pools and zvols
##########
zpool create $pool_options -O mountpoint=/mnt/data_pool data_pool raidz2 $data_pool_devices
# when you get to this step, you probably cannot create the or near the maximum volume size you think you can.
# Once the new pool was created, zpool list showed this:
#
# root@lcs-s1:~# zpool list
# NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
# data_pool0  9.81T  3.22M  9.81T        -         -     0%     0%  1.00x    ONLINE  -
# data_pool1  9.81T  1.27M  9.81T        -         -     0%     0%  1.00x    ONLINE  -
# meta_pool0   238G  6.42M   238G        -         -     0%     0%  1.00x    ONLINE  -
#
# I started at 9.5T but it said :cannot create 'data_pool0/data_zvol0': out of space
# So, I started at the low end and worked my way up. I repeated the following until I got a value that worked:
#
# root@lcs-s1:~# zfs create -V 1.5T data_pool0/data_zvol0
# root@lcs-s1:~# zfs destroy data_pool0/data_zvol0

# zfs create -V 6.25T data_pool0/data_zvol0
zfs create -V 12.825T data_pool0/data_zvol0  # switched to one big pool becuase it made more sense
mkfs.xfs -s size=4k /dev/zvol/data_pool/data_zvol
mkdir -p /mnt/beegfs-data
mount /dev/zvol/data_pool/data_zvol /mnt/beegfs-data
echo "/dev/zvol/data_pool/data_zvol /mnt/beegfs-data xfs defaults 0 0" >> /etc/fstab

# zpool create $pool_options -O mountpoint=/mnt/data_pool1 data_pool1 raidz2 $data_pool1_devices
# zfs create -V 6.25T data_pool1/data_zvol1
# mkfs.xfs -s size=4k /dev/zvol/data_pool1/data_zvol1
# mkdir -p /mnt/beegfs-data1
# mount /dev/zvol/data_pool1/data_zvol1 /mnt/beegfs-data1
# echo "/dev/zvol/data_pool1/data_zvol1 /mnt/beegfs-data1 xfs defaults 0 0" >> /etc/fstab
