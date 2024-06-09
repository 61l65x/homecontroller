#!/bin/bash

# Run nmap to scan the local network and find devices with port 22 open (SSH)
nmap_output=$(nmap -p 22 --open -oG - 192.168.2.0/24)

# Use grep to extract the IP address of the Raspberry Pi
local_ip=$(hostname -I | cut -d' ' -f1) # Get the first IP address in the list

# Extract IP addresses other than the local one with port 22 open
raspberry_pi_ip=$(echo "$nmap_output" | awk -v local_ip="$local_ip" '/22\/open/ && $2 != local_ip {print $2}')

# Check if an IP address was found
if [ -n "$raspberry_pi_ip" ]; then
    echo "Raspberry Pi found at IP address: $raspberry_pi_ip"
    
    # You can add SSH connection or other commands here if needed
else
    echo "Raspberry Pi not found on the network or port 22 is not open on any other device"
fi

