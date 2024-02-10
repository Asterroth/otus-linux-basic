#!/bin/bash

if [ $# -ne 2 ]; then # Checking if two arguments are passed or not 
    echo "$0 <nameserver1> <nameserver2>" # Printing usage message if not passed correctly 
    exit 1 # Exiting script with error code 1 
fi  # End of argument checking block 1 
  
nameservers=$(grep -v '^#' /etc/resolv.conf | grep 'nameserver' | awk '{print $2}') # Assigning nameservers from /etc/resolv.conf to variable 
  
if [[ "$nameservers" == *"$1"* ]] && [[ "$nameservers" == *"$2"* ]]; then # Checking if both arguments are present in /etc/resolv.conf 
    echo "Both nameservers ($1 and $2) are present in /etc/resolv.conf" # Printing message if both arguments are present 
else # Else block for case when any of the arguments are not present in /etc/resolv.conf 
    echo "Either nameserver ($1 or $2) is not present in /etc/resolv.conf" # Printing message if any of arguments are not present 
fi # End of if block 2 