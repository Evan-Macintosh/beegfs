#!/bin/bash
# change 838.4G to whatever size you see from lsblk
systemctl stop multipathd.service
for HDD in $(lsblk | grep 838.4G | awk '{printf "%s ",$1}'); do multipath -a /dev/$HDD; done
systemctl start multipathd.service
echo ""
multipath -ll