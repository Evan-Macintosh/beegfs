#!/bin/bash
apt install multipath-tools device-mapper zfsutils-linux xfsprogs
systemctl stop multipathd.service
