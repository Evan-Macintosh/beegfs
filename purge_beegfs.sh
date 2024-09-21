#!/bin/bash
systemctl stop beegfs-storage.service
systemctl stop beegfs-meta.service
systemctl stop beegfs-mgmtd.service
dpkg --purge beegfs-common beegfs-meta beegfs-mgmtd beegfs-storage beegfs-utils
rm -rf /data/beegfs/
rm -rf /etc/beegfs/