#!/bin/bash -e

if [ `id -u` != 0 ]
then
    echo "$0: Run this script as root!"
    exit 1
fi

./config/packages-downloader.sh

echo 'base' > /etc/hostname

rm -f /etc/netplan/*.yaml

cp ./config/99-basic-config.yaml /etc/netplan/

netplan apply
