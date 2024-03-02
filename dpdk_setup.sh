#!/bin/bash
# No need to use sudo here
# Download the DPDK source file
wget http://fast.dpdk.org/rel/dpdk-23.07.tar.xz
tar xJf dpdk-23.07.tar.xz
rm dpdk-23.07.tar.xz
cd dpdk-23.07
# Configure DPDK build 
meson setup build
cd build
ninja
ninja install 
sudo ldconfig