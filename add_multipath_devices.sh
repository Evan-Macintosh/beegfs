#!/bin/bash
# change 838.4G to whatever size you see from lsblk
systemctl stop multipathd.service
for HDD in $(lsblk | grep 838.4G | awk '{printf "%s ",$1}'); do multipath -a /dev/$HDD; done  # 900GB SAS HDDs
for HDD in $(lsblk | grep 186.3G | awk '{printf "%s ",$1}'); do multipath -a /dev/$HDD; done  # 200GB SAS SSDs
modprobe dm_multipath	# to make sure it's really there
systemctl start multipathd.service
multipath -ll
