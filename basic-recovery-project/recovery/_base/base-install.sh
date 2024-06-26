#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

downloader='./config/package-downloader.sh'
netplan_conf_dir='/etc/netplan'
netplan_yaml='./config/00-basic-config.yaml'
hostname='basic'

"$downloader"
[ ! -e "$netplan_conf_dir/*" ] || rm "$netplan_conf_dir/*"
cp "$netplan_yaml" "$netplan_conf_dir/"
netplan apply
echo "$hostname" > /etc/hostname