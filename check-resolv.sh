#!/bin/bash

if [ $# -ne 2 ]; then
  echo "You need to provide two arguments (DNS servers)"
  exit 1
fi

dns1=$1
dns2=$2

if ! dig +short @$dns1 google.com > /dev/null; then
  echo "First argument '$dns1' is not DNS server"
  exit 1
fi

if ! dig +short @$dns2 google.com > /dev/null; then
  echo "Second argument '$dns2' is not DNS server"
  exit 1
fi

nameservers=$(grep -v '^#' /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')
echo "Nameservers currently specified in /etc/resolv.conf:"
echo "==============="
echo "$nameservers"
echo ""