#!/bin/bash
# change 838.4G to whatever size you see from lsblk
systemctl stop multipathd.service
for HDD in $(lsblk | grep 838.4G | awk '{printf "%s ",$1}'); do multipath -a /dev/$HDD; done
modprobe dm_multipath	# to make sure it's really there
systemctl start multipathd.service
echo ""
multipath -ll
