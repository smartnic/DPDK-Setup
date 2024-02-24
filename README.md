# DPDK Setup
> The steps mentioned here were tested on various Cloudlab machines. If these steps don't work, refer to the DPDK [documentation](https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html) 
## 1. Downloading and setting up DPDK
> Before starting, if you're NIC uses flow bifurcation (mostly used by Mellanox/NVIDIA NICs. Verify [here](https://doc.dpdk.org/guides/nics/index.html)), it is better to follow step **2.2** first and then return to step 1. DPDK selects which Poll Mode Drivers to install based on your machine's configuration. So, it is important that you configure NVIDIA OFED **before** installing DPDK. You can start from step 1 if you are using `vfio-pci` drivers.
- Run `sudo bash dpdk_prereq.sh`
- Update \$PATH variable using `export PATH=$PATH:$HOME/.local/bin`
- Install meson and ninja using `pip3 install meson ninja pyelftools`
- Run `bash dpdk_setup.sh`
## 2. NIC configuration

### 2.1 Using `vfio-pci` drivers
- IOMMU is required to make full use of the VFIO functionality. To verify if IOMMU is enabled, run `sudo dmesg | grep -i -e DMAR -e IOMMU`. You should see a message similar to this which specifies which IOMMU group a PCI port belongs to
```
[   11.385867] pci 0000:ff:16.0: Adding to iommu group 87
[   11.405414] pci 0000:ff:16.1: Adding to iommu group 87
[   11.416050] pci 0000:ff:16.2: Adding to iommu group 87
[   11.472783] DMAR: Intel(R) Virtualization Technology for Directed I/O
```
- If IOMMU is not enabled, we have to update the GRUB file and restart the machine.
    - Edit the GRUB file using `sudo nano /etc/default/grub`
    - Add the following options to the line  `GRUB_CMDLINE_LINUX_DEFAULT=""` 
        - For Intel CPU: `intel_iommu=on`
        - For AMD CPU: `amd_iommu=on`
    - Update GRUB `sudo update-grub` and reboot the system `sudo reboot`.
- Use `./dpdk-23.07/usertools/dpdk-devbind.py --status` to check the status of the network interfaces. If there are no devices listed in \'Network devices using DPDK-compatible drive,\' we need to bind them to `vfio-pci`.

> We cant update the driver when a network interface is active. Use `ifconfig <if_name> down` to deactivate it.

- To bind the interface to the vfio-pci driver, use `sudo ./dpdk-23.07/usertools/dpdk-devbind.py --bind=vfio-pci <PCI-port-num>` and verify its status by running devbind using the `--status` flag
> If you still get errors when binding, try using the `uio_pci_generic` module instead of the `vfio-pci` module. The details can be found in the [documentation](https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html) 

### 2.2 Using Mellanox/NVIDIA drivers
- Download the appropriate Linux drivers based on your device's configuration from [NVIDIA's website](https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/)
> This sample includes the steps for installing OFED version 5.8 for an Ubuntu 22.04 machine and kernel version 5.15.0-86-generic. Just updating the parameters based on your machine's configuration should work fine. However, if there are some issues, the detailed installation instructions can be found [here](https://docs.nvidia.com/networking/display/mlnxofedv561033/installing+mlnx_ofed)

```
mkdir /mnt/mlnx

mount -o ro,loop MLNX_OFED_LINUX-5.8-4.1.5.0-ubuntu22.04-x86_64.iso /mnt/mlnx

/mnt/mlnx/mlnxofedinstall --dpdk --without-dkms --add-kernel-support --kernel 5.15.0-86-generic --without-fw-update --force
```
> The `--dpdk` flag will be required irrespective of any configuration changes to ensure that the appropriate PMDs are configured.

> Based on the output of the installation step, you might have to run some commands (which will be explained in the terminal output). If there are any doubts, refer to the installation [steps]((https://docs.nvidia.com/networking/display/mlnxofedv561033/installing+mlnx_ofed))

## 3. Setting up Hugepages
> Typically, you have to mount huge pages before running any DPDK application. You might also have to mount hugepages after restarting the machine.

- DPDK has a program which mounts hugepages and reserves them.
```
sudo python3 ./dpdk-23.07/usertools/dpdk-hugepages.py -p 1G --setup 2G
```
- This will setup 2 - 1GB hugepages.
## Compiling the sample DPDK Applications
- Go to the DPDK build directory
-  ```$ meson configure -Dexamples=all``` to enable examples compilation
> To compile a specific example, use ```$ meson configure -Dexamples=<example_folder_name>``` instead

- ```$ ninja``` to build the examples
- To run the sample applications, refer to the [user guides](https://doc.dpdk.org/guides/sample_app_ug/index.html)

## Using testpmd to transmit packets
> Important: Verify the connection of the traffic generator and the DPDK application before running the examples.
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
