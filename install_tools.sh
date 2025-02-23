#!/bin/bash
# https://www.cyberciti.biz/faq/installing-zfs-on-debian-12-bookworm-linux-apt-get/
sed -r -i'.BAK' 's/^deb(.*)$/deb\1 contrib/g' /etc/apt/sources.list
apt update
apt install multipath-tools device-mapper zfsutils-linux xfsprogs zfs-zed
systemctl stop multipathd.service
