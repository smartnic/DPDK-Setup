#!/bin/bash
# Use sudo to run this file
apt-get update
# Install the general development tools
apt install build-essential
# Install pip
apt install python3-pip
# Install libnuma dev
apt-get install libnuma-dev
# Install pkg-config
apt-get install pkg-config

# Use usertools/dpdk-hugepages.py to mount hugepages instead
# Reserve 2 - 1GB pages
# echo 2 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
# # Make the memory available for DPDK to use
# mkdir -p /mnt/huge
# mount -t hugetlbfs pagesize=1GB /mnt/huge
# # Make the mount permanent across reboots
# echo nodev /mnt/huge hugetlbfs pagesize=1GB 0 0 >> /etc/fstab