#!/bin/bash
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
##########
### MODIFY THESE
##########
meta_pool0_devices="/dev/dm- /dev/dm-"

##########
### create the metadata pool and zvol
##########
# mdadm --create beegfs-metadata -n 2 -l 1 -N bgfs-meta $meta_pool0_devices # this sucks, why did i do this?
# mkfs.ext4 -i 2048 -I 512 -J size=400 -Odir_index,filetype /dev/md127
zpool create $pool_options -O mountpoint=/mnt/meta_pool0 meta_pool0 mirror $meta_pool0_devices
zfs create -V 200GB meta_pool/meta_zvol
mkfs.ext4 -i 2048 -I 512 -J size=400 -Odir_index,filetype /dev/zvol/meta_pool0/meta_zvol
mkdir -p /mnt/beegfs-meta
mount /dev/zvol/meta_pool0/meta_zvol /mnt/beegfs-meta
echo "/dev/zvol/meta_pool0/meta_zvol /mnt/beegfs-meta ext4 defaults 0 0" >> /etc/fstab
