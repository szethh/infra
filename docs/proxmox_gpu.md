# setup stuff from here

https://www.reddit.com/r/homelab/comments/b5xpua/the_ultimate_beginners_guide_to_gpu_passthrough/

10de:1c03
10de:10f1


echo "options vfio-pci ids=10de:1c03,10de:10f1 disable_vga=1"> /etc/modprobe.d/vfio.conf


https://www.youtube.com/watch?v=BoMlfk397h0



if code 43 on gpu, mount cdrom with virtio tools and run the executable `virtio-win-guest-tools`



https://forum.proxmox.com/threads/pci-gpu-passthrough-on-proxmox-ve-8-installation-and-configuration.130218/

https://forum.proxmox.com/threads/pci-gpu-passthrough-on-proxmox-ve-8-windows-10-11.131002/

GP.rom is obtained from gpu-z

python3 nvidia_vbios_vfio_patcher.py -i GP.rom -o /usr/share/kvm/gtx1060_2.rom







/etc/pve/qemu-server/101.conf

args: -cpu 'host,hv_ipi,hv_relaxed,hv_reset,hv_runtime,hv_spinlocks=0x1fff,hv_stimer,hv_synic,hv_time,hv_vapic,hv_vpindex,kvm=off,+kvm_pv_eoi,+kvm_pv_unhalt,+pcid,hv_vendor_id=NV43FIX'


# windows autologin

install windows sysinternals and run Autologon64, input password.

activate windows with [MAS](https://github.com/massgravel/Microsoft-Activation-Scripts)

set steam custom logos from [steam grid db](https://www.steamgriddb.com)