#!/bin/bash

if [ $# -ne 2 ]; then # Checking if two arguments are passed or not 
    echo "Please use as following: $0 <nameserver1> <nameserver2>" # Printing usage message if not passed correctly 
    exit 1 # Exiting script with error code 1 
fi  # End of argument checking block 1

nameservers=$(grep -v '^#' /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')
echo "Nameservers specified in /etc/resolv.conf:"
echo "==============="
echo "$nameservers"
echo ""

if [[ "$nameservers" == *"$1"* ]]; then
  echo "Nameserver $1 is present in /etc/resolv.conf"
else
  echo "Nameserver $1 are NOT present in /etc/resolv.conf"
fi

if [[ "$nameservers" == *"$2"* ]]; then
  echo "Nameserver $2 is present in /etc/resolv.conf"
else
  echo "Nameserver $2 is NOT present in /etc/resolv.conf"
fi