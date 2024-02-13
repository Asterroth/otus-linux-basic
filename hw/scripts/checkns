#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Please provide two arguments (DNS servers)"
  echo "Usage: $0 <nameserver1> <nameserver2>"
  exit 1
fi

dns1=$1
dns2=$2

if ! dig +short @$dns1 google.com > /dev/null; then
  echo "'$dns1' is not DNS server"
  exit 1
fi

if ! dig +short @$dns2 google.com > /dev/null; then
  echo "'$dns2' is not DNS server"
  exit 1
fi

if ! test -w /etc/resolv.conf; then
  echo "The current user '$(whoami)' doesn't have permission to edit /etc/resolv.conf"
  exit 1
fi

if ! grep -q "^nameserver $dns1" /etc/resolv.conf; then
  echo "/etc/resolv.conf does not match the settings: nameserver $dns1 is missing."
  echo "nameserver $dns1" >> /etc/resolv.conf
  echo "$dns1 added to /etc/resolv.conf"
fi

if ! grep -q "^nameserver $dns2" /etc/resolv.conf; then
  echo "/etc/resolv.conf does not match the settings: nameserver $dns2 is missing."
  echo "nameserver $dns2" >> /etc/resolv.conf
  echo "$dns2 added to /etc/resolv.conf"
fi

nameservers=$(grep -v '^#' /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')

echo "Current settings of DNS servers in /etc/resolv.conf:"
echo "----------------"
echo "$nameservers"
