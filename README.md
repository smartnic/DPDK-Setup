# DPDK Setup
> The steps mentioned here were tested on various Cloudlab clusters. If these steps don't work, refer to the DPDK [documentation](https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html) 
- Run `$ sudo bash dpdk_prereq.sh`
-  Install meson and ninja using `$ pip3 install meson ninja pyelftools`
- Update \$PATH variable using `$ export PATH=$PATH:$HOME/.local/bin`
- Run `$ bash dpdk_setup.sh`
- `$ ./dpdk-23.07/usertools/dpdk-devbind.py --status` to check the status of NICs. If there are no devices listed in \'Network devices using DPDK-compatible drive,\' we need to bind them to `vfio-pci`.
> In Cloudlab, by default, when we try to bind using `vfio-pci`, we get `error -22`. This is because there is no default support for IOMMU. So, we need to update the GRUB file
- Edit the GRUB file using `$ sudo nano /etc/default/grub`
- Add the following options to the line  `GRUB_CMDLINE_LINUX_DEFAULT=""` 
    - For Intel CPU: `intel_iommu=on`
    - For AMD CPU: `amd_iommu=on`
- Update GRUB `$ sudo update-grub` and reboot the system.
> The Hugepage configuration might have been reset after reboot. So, if the examples don't work, try running the `echo 2 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages` command again to reserve 2, 1GB hugepages.
- To verify that IOMMU is enabled, run `$ sudo dmesg | grep -i -e DMAR -e IOMMU`. You should find a message similar to this (For Intel CPU)
```
[   11.385867] pci 0000:ff:16.0: Adding to iommu group 87
[   11.405414] pci 0000:ff:16.1: Adding to iommu group 87
[   11.416050] pci 0000:ff:16.2: Adding to iommu group 87
[   11.472783] DMAR: Intel(R) Virtualization Technology for Directed I/O
```

- If the NIC is active, we need to deactivate it using `$ ifconfig <if_name> down`
- `$ sudo ./dpdk-23.07/usertools/dpdk-devbind.py --bind=vfio-pci <PCI-port-num>` and check the status
> If you still get errors when binding, try using the `uio_pci_generic` module instead of the `vfio-pci` module. The details can be found in the [documentation](https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html) 

## Compiling the sample DPDK Applications
- Go to the DPDK build directory
-  ```$ meson configure -Dexamples=all``` to enable examples compilation
> To compile a specific example, use ```$ meson configure -Dexamples=<example_folder_name>``` instead

- ```$ ninja``` to build the examples
- To run the sample applications, refer to the [user guides](https://doc.dpdk.org/guides/sample_app_ug/index.html)

> Important: Ensure that the NIC that receives the network packets uses a DPDK-compatible driver and is connected to the same network as the transmitter. Also, verify the source and destination MAC address.
## Using testpmd to transmit packets
- Inside the build directory, run the following command to start testpmd
```
sudo ./app/dpdk-testpmd -l 0-3 -n 4 -- -i --portmask=0x1 --nb-cores=2
```
- To start the port `port start <port-no>`
- To show the port status `show port info <port-no>`
- To set the packet forwarding mode `set fwd txonly`
- To set the destination `set eth-peer <port-no> <dest-mac-addr>`
- To start the transmission `start`
- To stop the transmission `stop`
## Sources
- https://doc.dpdk.org/guides/index.html
- https://askubuntu.com/questions/1406888/ubuntu-22-04-gpu-passthrough-qemu
