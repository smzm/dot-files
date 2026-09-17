# Arch Linux + Hyprland Modern Installation Guide

# 1. Installation Philosophy

## 1.1 Main goals

The resulting system should be:

```text
Fast
Stable
Wayland-native
GPU-aware
HiDPI-friendly
Easy to troubleshoot
Easy to recover
Minimal in unnecessary packages
```

The guide does NOT attempt to reproduce Omarchy package-for-package.

Instead, it takes useful architectural ideas from Omarchy and keeps them compatible with normal Arch Linux.

---

## 1.2 Important principle

Do not solve every problem by adding packages.

For example:

```text
Blurry font
    ↓
Do not immediately install 10 font packages.

First check:
    Wayland vs XWayland
    compositor scaling
    application scaling
    Fontconfig
    FreeType
    toolkit behavior
```

Likewise:

```text
GPU problem
    ↓
Do not immediately add random NVIDIA kernel parameters.

First check:
    driver
    DRM modesetting
    GPU selection
    monitor connection
    render device
    logs
```

---

# 2. Target Architecture

## 2.1 Basic system

```text
UEFI
  |
  +-- GPT
       |
       +-- EFI System Partition
       |      1 GiB FAT32
       |
       +-- Linux root
              ext4
```

---

## 2.2 Graphics

```text
                    +-----------------------+
                    |       Hyprland        |
                    +-----------+-----------+
                                |
                    primary renderer
                                |
                 +--------------+--------------+
                 |                             |
              Intel                         NVIDIA
                 |                             |
        Desktop / browser             PRIME offload
        video decode                  games / GPU apps
```

The actual arrangement depends on:

```text
which GPU is connected to the monitor
which GPU should render the compositor
which workloads should use NVIDIA
```

---

## 2.3 Desktop services

```text
Ly
 |
 +-- UWSM
      |
      +-- Hyprland
           |
           +-- Waybar
           +-- Hypridle
           +-- Hyprpaper
           +-- Hyprpolkitagent
           +-- PipeWire
           +-- GNOME Keyring
           +-- applications
```

---

# 3. Firmware Preparation

## 3.1 Use UEFI

Use:

```text
UEFI
GPT
CSM/Legacy disabled
```

Check the Arch ISO later with:

```bash
test -d /sys/firmware/efi/efivars \
    && echo "UEFI mode detected" \
    || echo "NOT booted in UEFI mode"
```

Expected:

```text
UEFI mode detected
```

---

## 3.2 Secure Boot

For the first installation:

```text
Secure Boot: disabled
```

Secure Boot can be added later.

A complete Secure Boot setup is a separate project involving:

```text
UEFI keys
sbctl
signed EFI files
signed UKIs
NVIDIA modules
bootloader configuration
```

Do not partially configure Secure Boot.

---

## 3.3 Intel integrated graphics

If your firmware provides an option such as:

```text
Internal Graphics
Integrated Graphics
iGPU Multi-Monitor
IGD Multi-Monitor
```

enable it when you want Linux to expose both Intel and NVIDIA GPUs.

---

## 3.4 Intel VMD / RAID

If Arch cannot see your NVMe disk:

```text
Check Intel VMD
Check Intel RST
Check RAID mode
```

Do not blindly disable VMD on an existing Windows installation.

Changing storage-controller mode can prevent Windows from booting if Windows was installed under a different mode.

---

# 4. Identify the Installation Disk

## 4.1 List disks

From the Arch ISO:

```bash
lsblk -o NAME,SIZE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS,MODEL
```

Also:

```bash
lsblk -dpno NAME,SIZE,MODEL,TRAN
```

Example:

```text
/dev/nvme0n1  931.5G  Samsung SSD 980 PRO  nvme
/dev/sda       29.1G  USB Drive             usb
```

In this example:

```text
/dev/nvme0n1
```

is the installation disk.

Never blindly copy a disk name from this guide.

---

# 5. Create the Arch USB

## 5.1 Verify the USB device

```bash
lsblk -dpno NAME,SIZE,MODEL,TRAN
```

Use the whole USB device.

Correct:

```text
/dev/sdb
```

Incorrect:

```text
/dev/sdb1
```

---

## 5.2 Write the ISO

Using a stable `/dev/disk/by-id` path is preferable.

```bash
sudo dd \
    bs=4M \
    if=archlinux-<VERSION>-x86_64.iso \
    of=/dev/disk/by-id/usb-<YOUR_USB_DEVICE> \
    conv=fsync \
    oflag=direct \
    status=progress
```

Then:

```bash
sync
```

WARNING:

```text
dd destroys the partition table of the output device.
```

Verify:

```bash
of=
```

before executing.

---

# 6. Boot the Arch ISO

## 6.1 Verify UEFI

```bash
test -d /sys/firmware/efi/efivars \
    && echo "UEFI mode detected" \
    || echo "NOT booted in UEFI mode"
```

Stop if the result says:

```text
NOT booted in UEFI mode
```

---

# 7. Keyboard Layout

## 7.1 Console keyboard

List layouts:

```bash
localectl list-keymaps
```

Example:

```bash
loadkeys us
```

German:

```bash
loadkeys de
```

This changes the temporary console layout.

It does not configure Hyprland.

---

# 8. Network During Installation

## 8.1 Ethernet

Ethernet normally works automatically.

Test:

```bash
ping -c 3 ping.archlinux.org
```

---

## 8.2 Wi-Fi

Start:

```bash
iwctl
```

Then:

```text
device list
```

Find the wireless interface.

Example:

```text
wlan0
```

Scan:

```text
station wlan0 scan
```

List:

```text
station wlan0 get-networks
```

Connect:

```text
station wlan0 connect "YOUR_WIFI"
```

Exit:

```text
exit
```

Test:

```bash
ping -c 3 ping.archlinux.org
```

---

# 9. Time Synchronization

Enable NTP in the installer:

```bash
timedatectl set-ntp true
```

Check:

```bash
timedatectl status
```

---

# 10. Optional Mirror Optimization

## 10.1 Use the ISO mirrorlist first

The Arch ISO already contains a usable mirrorlist.

Do not replace it without a reason.

---

## 10.2 Optional reflector

Install:

```bash
pacman -Sy reflector
```

Then:

```bash
reflector \
    --protocol https \
    --latest 20 \
    --sort rate \
    --save /etc/pacman.d/mirrorlist
```

Inspect:

```bash
sed -n '1,20p' /etc/pacman.d/mirrorlist
```

Do not use:

```bash
pacman -Sy
```

as a normal installed-system update strategy.

Normal installed-system updating is:

```bash
pacman -Syu
```

---

# 11. Partition Layout

## 11.1 Recommended ext4 layout

For a clean UEFI Arch installation:

```text
/dev/nvme0n1p1    1 GiB      EFI System Partition
/dev/nvme0n1p2    remaining  Linux root
```

This guide does not require a separate:

```text
/home
swap
/boot
```

partition.

---

## 11.2 Create partitions

```bash
cfdisk /dev/nvme0n1
```

Select:

```text
GPT
```

Create:

```text
Partition 1
Size: 1G
Type: EFI System
```

Create:

```text
Partition 2
Size: remaining
Type: Linux filesystem
```

Write changes.

Verify:

```bash
lsblk -f /dev/nvme0n1
```

---

## 11.3 Existing Windows installation

Do not format the existing Windows EFI System Partition.

Find it:

```bash
lsblk -f
```

Look for:

```text
vfat
EFI System
```

Only format an ESP if it was created for this Arch installation.

---

# 12. Format Filesystems

## 12.1 EFI partition

Only for a newly created ESP:

```bash
mkfs.fat -F 32 /dev/nvme0n1p1
```

WARNING:

Do not run this against a Windows ESP.

---

## 12.2 Root

```bash
mkfs.ext4 -L arch-root /dev/nvme0n1p2
```

Verify:

```bash
lsblk -f
```

---

# 13. Mount Filesystems

Choose one bootloader layout.

---

## 13.1 systemd-boot or Limine

Mount ESP at:

```text
/boot
```

```bash
mount /dev/nvme0n1p2 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

---

## 13.2 GRUB

Mount ESP at:

```text
/boot/efi
```

```bash
mount /dev/nvme0n1p2 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot/efi
```

---

# 14. Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Inspect:

```bash
cat /mnt/etc/fstab
```

The root and EFI filesystems should be present.

UUIDs are preferred to raw `/dev/...` paths.

---

# 15. Install the Base Arch System

## 15.1 Base packages

```bash
pacstrap -K /mnt \
    base \
    linux \
    linux-firmware \
    intel-ucode \
    base-devel \
    networkmanager \
    sudo \
    git \
    vim
```

Optional editor:

```bash
pacstrap -K /mnt nano
```

---

## 15.2 Why these packages?

```text
base
    Arch Linux base userland

linux
    Official Arch kernel

linux-firmware
    Hardware firmware

intel-ucode
    Intel microcode

base-devel
    AUR/build toolchain

networkmanager
    Installed-system network management

sudo
    Privilege escalation

git
    Development/AUR workflows

vim
    Configuration editor
```

Keep the initial system small.

---

# 16. Enter the Installed System

```bash
arch-chroot -S /mnt
```

---

# 17. Configure Time Zone

Example:

```bash
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
```

Replace with your actual timezone.

Then:

```bash
hwclock --systohc
```

Use UTC for the hardware clock unless you deliberately choose another design.

---

# 18. Configure Locale

Edit:

```bash
vim /etc/locale.gen
```

Uncomment:

```text
en_US.UTF-8 UTF-8
```

Optional:

```text
de_DE.UTF-8 UTF-8
```

Generate:

```bash
locale-gen
```

Set default:

```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

---

# 19. Console Keyboard

Example:

```bash
echo "KEYMAP=us" > /etc/vconsole.conf
```

German:

```bash
echo "KEYMAP=de" > /etc/vconsole.conf
```

This affects virtual terminals.

Hyprland input is configured later.

---

# 20. Hostname

Example:

```bash
echo "archpc" > /etc/hostname
```

---

# 21. Hosts File

Create:

```bash
vim /etc/hosts
```

Use:

```text
127.0.0.1   localhost
::1         localhost
127.0.1.1   archpc.localdomain archpc
```

Do not disable IPv6 globally.

---

# 22. Configure NetworkManager + systemd-resolved

This guide intentionally uses:

```text
NetworkManager
+
systemd-resolved
```

The result is:

```text
NetworkManager
      |
      | connection/DHCP/VPN information
      v
systemd-resolved
      |
      +-- DNS caching
      +-- per-link DNS
      +-- split DNS
      +-- DNS-over-TLS
      |
      v
127.0.0.53
```

---

## 22.1 Tell NetworkManager to use systemd-resolved

Create:

```bash
mkdir -p /etc/NetworkManager/conf.d
```

Create:

```bash
vim /etc/NetworkManager/conf.d/dns.conf
```

Use:

```ini
[main]
dns=systemd-resolved
```

---

## 22.2 Enable systemd-resolved

```bash
systemctl enable systemd-resolved.service
```

---

## 22.3 Configure /etc/resolv.conf

Because this command should be performed outside the chroot, exit temporarily:

```bash
exit
```

In the Arch ISO environment:

```bash
ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
```

Then return:

```bash
arch-chroot -S /mnt
```

The installed system now has:

```text
/etc/resolv.conf
    ->
/run/systemd/resolve/stub-resolv.conf
```

---

## 22.4 Enable NetworkManager

```bash
systemctl enable NetworkManager.service
```

Do not simultaneously enable:

```text
dhcpcd
netctl
systemd-networkd
```

as competing network managers.

---

# 23. DNS Management

## 23.1 Check DNS state

After boot:

```bash
resolvectl status
```

Global DNS:

```bash
resolvectl dns
```

Current resolver:

```bash
resolvectl status | less
```

---

## 23.2 Configure DNS per NetworkManager connection

List connections:

```bash
nmcli connection show
```

Example:

```bash
nmcli connection modify "Ethernet" \
    ipv4.ignore-auto-dns yes \
    ipv4.dns "1.1.1.1 9.9.9.9"
```

For IPv6:

```bash
nmcli connection modify "Ethernet" \
    ipv6.ignore-auto-dns yes \
    ipv6.dns "2606:4700:4700::1111 2620:fe::9"
```

Reconnect:

```bash
nmcli connection down "Ethernet"
nmcli connection up "Ethernet"
```

Check:

```bash
resolvectl status
```

---

## 23.3 Use router DNS automatically

For normal DHCP:

```bash
nmcli connection modify "YOUR_CONNECTION" \
    ipv4.ignore-auto-dns no
```

This allows NetworkManager to pass DHCP DNS information to systemd-resolved.

---

## 23.4 DNS-over-TLS

Optional.

Create:

```bash
mkdir -p /etc/systemd/resolved.conf.d
vim /etc/systemd/resolved.conf.d/dns-over-tls.conf
```

Example:

```ini
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net
DNSOverTLS=yes
Domains=~.
```

Restart:

```bash
systemctl restart systemd-resolved.service
```

Check:

```bash
resolvectl status
```

Do not combine several unrelated DNS daemons.

---

# 24. Create User

Example:

```bash
useradd -m -G wheel -s /bin/bash smzm
```

Set password:

```bash
passwd smzm
```

Replace:

```text
smzm
```

with your username.

---

# 25. Configure sudo

Install if necessary:

```bash
pacman -S sudo
```

Edit:

```bash
EDITOR=vim visudo
```

Uncomment:

```text
%wheel ALL=(ALL:ALL) ALL
```

Test after reboot:

```bash
sudo -v
```

---

# 26. Optional Zsh

Install:

```bash
pacman -S zsh
```

Change shell:

```bash
chsh -s /bin/zsh smzm
```

Verify:

```bash
getent passwd smzm
```

---

# 27. Configure Pacman

Edit:

```bash
vim /etc/pacman.conf
```

Make sure these options are enabled:

```ini
[options]

Color
VerbosePkgLists
ParallelDownloads = 5
```

Do not copy Omarchy-specific repositories into a normal Arch installation.

Do not add:

```text
[omarchy]
```

to an Arch installation unless you intentionally want to turn the machine into an Omarchy-derived system.

---

## 27.1 Optional multilib

Uncomment:

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Then:

```bash
pacman -Syu
```

Multilib is useful for:

```text
Steam
Wine
Proton
32-bit applications
```

---

# 28. Kernel Modules Protection

Install:

```bash
pacman -S kernel-modules-hook
```

The package installs pacman hooks that preserve kernel modules across kernel upgrades.

No manual service startup is normally required.

Check installed hooks:

```bash
pacman -Ql kernel-modules-hook
```

You should see files under:

```text
/usr/share/libalpm/hooks/
```

This is particularly useful on systems using:

```text
NVIDIA
DKMS
external kernel modules
```

---

# 29. Bootloader Choice

Choose exactly ONE of:

```text
systemd-boot
GRUB
Limine
```

Recommended profiles:

```text
Simple modern system
    systemd-boot

Traditional / complicated multi-boot
    GRUB

Advanced modern / snapshot-oriented
    Limine
```

---

# 30. Bootloader Option A: systemd-boot

## 30.1 Install

The ESP must be mounted at:

```text
/boot
```

Install:

```bash
bootctl install
```

Verify:

```bash
bootctl status
```

---

## 30.2 Configure loader.conf

Create:

```bash
vim /boot/loader/loader.conf
```

Use:

```text
default arch.conf
timeout 3
console-mode max
editor no
```

---

## 30.3 Find root UUID

```bash
blkid -s UUID -o value /dev/nvme0n1p2
```

---

## 30.4 Create Arch entry

```bash
mkdir -p /boot/loader/entries
vim /boot/loader/entries/arch.conf
```

Use:

```text
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=YOUR-ROOT-UUID rw
```

Replace:

```text
YOUR-ROOT-UUID
```

with the actual UUID.

---

## 30.5 Verify

```bash
bootctl list
```

---

# 31. Bootloader Option B: GRUB

## 31.1 Install

The ESP must be mounted at:

```text
/boot/efi
```

Install:

```bash
pacman -S grub efibootmgr
```

---

## 31.2 Install GRUB

```bash
grub-install \
    --target=x86_64-efi \
    --efi-directory=/boot/efi \
    --bootloader-id=GRUB \
    --recheck
```

---

## 31.3 Generate configuration

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 31.4 Verify

```bash
efibootmgr -v
```

---

## 31.5 Windows detection

Install:

```bash
pacman -S os-prober
```

Edit:

```bash
vim /etc/default/grub
```

Set:

```text
GRUB_DISABLE_OS_PROBER=false
```

Then:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

Do not format the Windows ESP.

---

# 32. Bootloader Option C: Limine

Limine is a modern bootloader option with strong support for:

```text
UEFI
kernel entries
UKIs
snapshot workflows
```

It is particularly attractive for the optional:

```text
Btrfs + Snapper
```

configuration.

---

## 32.1 Install Limine

Use the ESP mounted at:

```text
/boot
```

Install:

```bash
pacman -S limine efibootmgr
```

---

## 32.2 Install the EFI bootloader

```bash
limine-install
```

Verify:

```bash
efibootmgr -v
```

---

## 32.3 Configure the kernel command line

Create:

```bash
vim /etc/kernel/cmdline
```

Basic configuration:

```text
root=UUID=YOUR-ROOT-UUID rw
```

Replace the UUID.

---

## 32.4 Generate/update Limine entries

```bash
limine-update
```

Inspect entries:

```bash
limine-list
```

If your installed package reports a configuration-generation error, inspect:

```bash
cat /etc/default/limine
```

and verify the detected ESP path.

---

## 32.5 Windows

Limine can chainload:

```text
EFI/Microsoft/Boot/bootmgfw.efi
```

You can also use:

```bash
limine-scan
```

to detect existing EFI boot entries where supported by the installed tooling.

---

## 32.6 Limine fallback path

For firmware that ignores NVRAM boot entries:

```bash
limine-install --fallback
```

Use this only when needed.

---

# 33. Install Intel Graphics

Install:

```bash
pacman -S \
    mesa \
    vulkan-intel \
    intel-media-driver \
    libva-utils
```

Verify:

```bash
lspci -k | grep -A3 -i Intel
```

Look for:

```text
Kernel driver in use: i915
```

---

## 33.1 Intel Vulkan

Install tools:

```bash
pacman -S vulkan-tools
```

Test:

```bash
vulkaninfo --summary
```

---

## 33.2 Intel VA-API

```bash
vainfo
```

The modern Intel media driver is usually:

```text
iHD
```

Do not globally force:

```text
LIBVA_DRIVER_NAME=i965
```

unless you specifically need the legacy driver.

---

# 34. Install NVIDIA

## 34.1 Modern supported NVIDIA hardware

Install:

```bash
pacman -S \
    nvidia-open \
    nvidia-utils \
    nvidia-prime \
    egl-wayland
```

For 32-bit applications after enabling multilib:

```bash
pacman -S lib32-nvidia-utils
```

---

## 34.2 Why nvidia-open instead of nvidia-open-dkms?

For the standard Arch kernel:

```text
linux
```

use:

```text
nvidia-open
```

DKMS is useful when you need to build the NVIDIA kernel module for:

```text
custom kernels
multiple unsupported kernels
special kernel configurations
```

Do not use DKMS simply because you expect better runtime GPU performance.

The rendering performance is not improved merely by changing:

```text
nvidia-open
```

to:

```text
nvidia-open-dkms
```

---

## 34.3 Verify driver

```bash
nvidia-smi
```

---

## 34.4 Verify DRM modesetting

```bash
cat /sys/module/nvidia_drm/parameters/modeset
```

Expected:

```text
Y
```

Modern NVIDIA packages enable DRM modesetting by default.

Do not blindly add:

```text
nvidia-drm.modeset=1
```

to the kernel command line.

---

# 35. NVIDIA Early KMS

Early NVIDIA module loading is optional.

Use it when:

```text
NVIDIA loads too late
display-manager startup is problematic
you need consistent early graphics initialization
```

Create:

```bash
vim /etc/mkinitcpio.conf.d/nvidia.conf
```

Use:

```text
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Then:

```bash
mkinitcpio -P
```

Verify:

```bash
lsinitcpio /boot/initramfs-linux.img | grep -E 'nvidia(_modeset|_uvm|_drm)?\.ko'
```

IMPORTANT:

Early NVIDIA KMS has a hibernation trade-off.

If hibernation is important, do not enable early NVIDIA KMS casually.

---

# 36. NVIDIA + Intel Hybrid GPU Detection

Run:

```bash
lspci -k | grep -A3 -E 'VGA|3D|Display'
```

You may see:

```text
00:02.0 VGA compatible controller: Intel ...
    Kernel driver in use: i915

01:00.0 VGA compatible controller: NVIDIA ...
    Kernel driver in use: nvidia
```

---

## 36.1 Identify DRM devices

```bash
ls -l /dev/dri/
```

Then:

```bash
ls -l /dev/dri/by-path/
```

Example:

```text
pci-0000:00:02.0-card
pci-0000:00:02.0-render

pci-0000:01:00.0-card
pci-0000:01:00.0-render
```

This is more reliable than assuming:

```text
card0 = Intel
card1 = NVIDIA
```

The card numbers can change.

---

# 37. Choose Hybrid GPU Strategy

There are two primary modes.

---

## 37.1 Profile A: NVIDIA primary

Use this when:

```text
your main monitor is physically connected to NVIDIA
you want maximum desktop GPU performance
you have a desktop with a powerful NVIDIA GPU
```

Architecture:

```text
Monitor
    |
    v
NVIDIA
    |
    v
Hyprland
```

Intel remains available as a secondary GPU.

---

## 37.2 Profile B: Intel primary

Use this when:

```text
display is connected to Intel
you want low dGPU activity
you want NVIDIA only for selected workloads
```

Architecture:

```text
Monitor
    |
    v
Intel
    |
    v
Hyprland
    |
    +---- prime-run ----> NVIDIA
```

---

# 38. Hyprland GPU Selection

Hyprland uses:

```text
AQ_DRM_DEVICES
```

The order determines priority.

For example:

```text
Intel first
NVIDIA second
```

means:

```text
Intel = primary
NVIDIA = available secondary
```

Hyprland also requires every GPU that physically owns a connected monitor to be included.

---

# 39. Create Stable GPU Paths

Do not permanently configure:

```text
/dev/dri/card0
/dev/dri/card1
```

Create stable udev names.

First:

```bash
lspci -D -d ::03xx
```

Example:

```text
0000:00:02.0 Intel ...
0000:01:00.0 NVIDIA ...
```

Create:

```bash
sudo vim /etc/udev/rules.d/60-dri-gpu.rules
```

Example:

```text
KERNEL=="card*", SUBSYSTEM=="drm", KERNELS=="0000:00:02.0", SYMLINK+="dri/intel"
KERNEL=="card*", SUBSYSTEM=="drm", KERNELS=="0000:01:00.0", SYMLINK+="dri/nvidia"
```

Replace the PCI addresses with your real addresses.

Reload:

```bash
sudo udevadm control --reload
sudo udevadm trigger
```

Check:

```bash
ls -l /dev/dri/intel
ls -l /dev/dri/nvidia
```

---

# 40. NVIDIA Primary

Use:

```text
AQ_DRM_DEVICES=/dev/dri/nvidia:/dev/dri/intel
```

This makes NVIDIA the preferred GPU while keeping Intel available.

---

# 41. Intel Primary

Use:

```text
AQ_DRM_DEVICES=/dev/dri/intel:/dev/dri/nvidia
```

This makes Intel the preferred renderer while keeping NVIDIA available.

---

# 42. PRIME Render Offload

Test:

```bash
prime-run glxinfo -B
```

Compare with:

```bash
glxinfo -B
```

Install if necessary:

```bash
pacman -S mesa-utils
```

---

## 42.1 Vulkan offload

```bash
prime-run vulkaninfo --summary
```

Compare with:

```bash
vulkaninfo --summary
```

---

## 42.2 Do not globally force NVIDIA on a hybrid Intel-primary system

Do NOT blindly set globally:

```text
LIBVA_DRIVER_NAME=nvidia
__GLX_VENDOR_LIBRARY_NAME=nvidia
NVD_BACKEND=direct
```

when Intel is the primary compositor/browser GPU.

This can force browser video decoding or GL selection onto NVIDIA while presentation happens through Intel.

That can create:

```text
cross-GPU DMA-BUF problems
browser GPU crashes
video corruption
extra dGPU power usage
```

Use per-application offload instead.

---

# 43. NVIDIA Video Decode Strategy

## 43.1 Intel primary

Prefer:

```text
Intel iHD
```

for the normal desktop/browser video path.

Verify:

```bash
vainfo
```

Do not set:

```bash
LIBVA_DRIVER_NAME=nvidia
```

globally.

---

## 43.2 NVIDIA primary

NVIDIA video acceleration can be used.

Optionally install:

```bash
pacman -S libva-nvidia-driver
```

Only do this when the NVIDIA VA-API path is actually desired.

Do not install it merely because NVIDIA exists in the machine.

---

# 44. NVIDIA Power Management

Check:

```bash
cat /proc/driver/nvidia/gpus/*/power
```

For hybrid systems, the goal is usually:

```text
NVIDIA can become idle
```

when no application needs it.

Check active GPU users:

```bash
nvidia-smi
```

If an unexpected application keeps the NVIDIA GPU active, inspect:

```bash
nvidia-smi
```

for its process.

---

# 45. NVIDIA Suspend / Hibernation

Modern NVIDIA drivers have changed how video-memory preservation works.

Check:

```bash
sort /proc/driver/nvidia/params
```

Look for:

```text
UseKernelSuspendNotifiers
```

On modern supported drivers, avoid manually enabling old NVIDIA suspend services just because older guides recommend them.

If your exact driver branch requires the services:

```bash
systemctl enable \
    nvidia-suspend.service \
    nvidia-resume.service \
    nvidia-hibernate.service
```

Check the installed driver documentation before doing this.

---

# 46. Do Not Use ibt=off by Default

Do not add:

```text
ibt=off
```

just because you use NVIDIA.

Use it only when logs demonstrate a specific problem that requires it.

It disables a CPU security feature.

---

# 47. Install Hyprland

Install:

```bash
pacman -S \
    hyprland \
    wayland \
    wayland-protocols \
    xorg-xwayland \
    wl-clipboard \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland
```

Current Hyprland packages already include many of the necessary graphics dependencies.

---

# 48. Hyprland Desktop Utilities

Install:

```bash
pacman -S \
    kitty \
    waybar \
    wofi \
    hyprpaper \
    hypridle \
    hyprlock \
    hyprcursor \
    hyprpicker \
    hyprsunset
```

---

# 49. Polkit + Hyprpolkitagent

Install:

```bash
pacman -S \
    polkit \
    hyprpolkitagent
```

IMPORTANT:

```text
polkit
    policy framework / daemon

hyprpolkitagent
    graphical authentication agent
```

Do NOT remove:

```text
polkit
```

just because you installed:

```text
hyprpolkitagent
```

They perform different jobs.

---

## 49.1 Start Hyprpolkitagent

After logging into the graphical session:

```bash
systemctl --user enable --now hyprpolkitagent.service
```

Check:

```bash
systemctl --user status hyprpolkitagent.service
```

Do not run multiple GUI authentication agents simultaneously.

---

# 50. PipeWire

Install:

```bash
pacman -S \
    pipewire \
    pipewire-audio \
    pipewire-alsa \
    pipewire-pulse \
    wireplumber
```

---

## 50.1 Start audio

```bash
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service
```

Verify:

```bash
wpctl status
```

---

# 51. Bluetooth

Install:

```bash
pacman -S \
    bluez \
    bluez-utils \
    blueman
```

Enable:

```bash
systemctl enable --now bluetooth.service
```

---

# 52. Universal Wayland Session Manager

UWSM wraps a Wayland compositor and its graphical applications in systemd user units.

It provides:

```text
session lifetime management
environment management
XDG autostart integration
systemd user integration
clean graphical-session shutdown
```

It is an advanced option.

---

## 52.1 Install UWSM

```bash
pacman -S uwsm
```

---

## 52.2 Why use UWSM?

Without UWSM:

```text
Ly
 |
 +-- Hyprland
       |
       +-- random autostart processes
       +-- background processes
       +-- GUI apps
```

With UWSM:

```text
Ly
 |
 +-- UWSM
       |
       +-- graphical session
             |
             +-- Hyprland
             +-- apps
             +-- user services
```

---

# 53. UWSM Environment Configuration

Create:

```bash
mkdir -p ~/.config/uwsm
```

For Hyprland-specific environment variables:

```bash
vim ~/.config/uwsm/env-hyprland
```

Use:

```bash
# Use native Wayland when applications support it.
export GDK_BACKEND="wayland,x11,*"

# Try Wayland first, then fall back to XWayland.
export QT_QPA_PLATFORM="wayland;xcb"

# Firefox versions that honor this variable use native Wayland.
# Modern Firefox already defaults to Wayland.
export MOZ_ENABLE_WAYLAND="1"

# Electron versions that still honor this variable.
# Modern Electron versions should use --ozone-platform=wayland instead.
export ELECTRON_OZONE_PLATFORM_HINT="wayland"

# Prefer Wayland for Chromium/Ozone-based applications that honor this.
export OZONE_PLATFORM="wayland"
```

Do not globally set NVIDIA-rendering variables here.

---

# 54. Modern Electron Wayland Configuration

Electron versions 38+ use native Wayland by default more often than older versions.

When an Electron application still uses XWayland:

Create:

```bash
mkdir -p ~/.config
vim ~/.config/electron-flags.conf
```

Use:

```text
--ozone-platform=wayland
```

For older applications, you may also need:

```text
--enable-features=WaylandWindowDecorations
```

Check the application's Electron version before adding compatibility flags.

Do not blindly use:

```text
--ozone-platform-hint=wayland
```

with modern Electron versions.

---

# 55. Firefox Wayland

Modern Firefox versions already default to Wayland.

Verify:

```text
about:support
```

Look for:

```text
Window Protocol
```

Expected:

```text
wayland
```

Avoid forcing Firefox through XWayland when sharp fractional scaling is the goal.

---

# 56. XWayland HiDPI Rendering

This is one of the most important rendering improvements in this guide.

Configure:

```lua
hl.config({
    xwayland = {
        force_zero_scaling = true,
    }
})
```

This prevents Hyprland from automatically rescaling XWayland windows in the usual blurry way.

The goal is:

```text
XWayland application
    |
    +-- render at its own logical scale
    |
    +-- application/toolkit handles scaling
    |
    +-- avoid compositor resampling
```

---

# 57. Important XWayland Warning

`force_zero_scaling` is not a magic "everything becomes bigger and sharper" option.

Some XWayland applications may become:

```text
too small
```

because they do not understand HiDPI themselves.

For those applications:

```text
configure application/toolkit scaling
```

rather than globally using:

```text
GDK_SCALE=2
```

or:

```text
QT_SCALE_FACTOR=2
```

---

# 58. Do Not Globally Use GDK_SCALE=2

On a display using:

```text
3440x1440
scale 1.25
```

do not globally set:

```bash
GDK_SCALE=2
```

This can make some applications incorrectly scaled.

Prefer:

```text
native Wayland
correct compositor scale
toolkit-native scaling
```

---

# 59. Rendering Environment Summary

The preferred rendering stack is:

```text
GTK
  |
  +-- Wayland

Qt
  |
  +-- Wayland
  +-- XWayland fallback

Firefox
  |
  +-- Wayland

Electron
  |
  +-- Wayland

Chromium/Brave
  |
  +-- Wayland/Ozone

X11-only applications
  |
  +-- XWayland
        |
        +-- force_zero_scaling
```

---

# 60. Font Rendering

The rendering stack is:

```text
Application
    |
    v
Fontconfig
    |
    v
FreeType
    |
    v
Wayland / toolkit
    |
    v
Hyprland
    |
    v
Monitor
```

Do not assume blurry text means the font file itself is bad.

---

# 61. Install Fonts

Install:

```bash
pacman -S \
    inter-font \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji
```

Inter:

```text
UI / normal text
```

JetBrains Mono:

```text
terminal / code
```

JetBrains Mono Nerd:

```text
terminal + symbols + icons
```

Noto:

```text
Unicode coverage
```

Noto Emoji:

```text
color emoji fallback
```

---

# 62. User Font Directory

Use:

```text
~/.local/share/fonts
```

Create:

```bash
mkdir -p ~/.local/share/fonts
```

Copy a downloaded font:

```bash
cp ~/Downloads/MyFont.ttf ~/.local/share/fonts/
```

Rebuild:

```bash
fc-cache -fv
```

---

# 63. Check Fontconfig

Check normal text:

```bash
fc-match sans-serif
```

Check monospace:

```bash
fc-match monospace
```

Check Inter:

```bash
fc-match Inter
```

Check JetBrains:

```bash
fc-match "JetBrains Mono"
```

---

# 64. Fontconfig Quality Defaults

Check the current FreeType configuration:

```bash
cat /etc/profile.d/freetype2.sh
```

Modern Arch already enables:

```text
anti-aliasing
hinting
TrueType bytecode interpretation
```

Do not install old "Infinality" font patches.

Do not automatically disable hinting.

---

# 65. Optional Fontconfig Fine Tuning

Create:

```bash
mkdir -p ~/.config/fontconfig
vim ~/.config/fontconfig/fonts.conf
```

A conservative quality-oriented configuration:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">

<fontconfig>

    <!-- Keep antialiasing enabled. -->
    <match target="font">
        <edit name="antialias" mode="assign">
            <bool>true</bool>
        </edit>
    </match>

    <!-- Light hinting is a good default for modern LCD displays. -->
    <match target="font">
        <edit name="hinting" mode="assign">
            <bool>true</bool>
        </edit>
    </match>

    <match target="font">
        <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
        </edit>
    </match>

    <!-- Most conventional LCD panels use RGB subpixel order. -->
    <match target="font">
        <edit name="rgba" mode="assign">
            <const>rgb</const>
        </edit>
    </match>

</fontconfig>
```

Then:

```bash
fc-cache -fv
```

Restart applications.

---

# 66. LCD Subpixel Rendering

Modern FreeType supports subpixel rendering.

For a conventional RGB-stripe LCD:

```text
rgb
```

is normally appropriate.

For BGR displays:

```text
bgr
```

may be appropriate.

For OLED/PenTile or unusual arrangements:

```text
none
```

may produce a cleaner result.

If color fringes appear around text:

```text
disable subpixel rendering
```

rather than increasing artificial sharpening.

---

# 67. LCD Filter

Optional:

```xml
<match target="font">
    <edit name="lcdfilter" mode="assign">
        <const>lcddefault</const>
    </edit>
</match>
```

If fonts look too fuzzy or heavy, test:

```text
lcdlight
```

Do not change several font parameters simultaneously.

---

# 68. Wayland vs XWayland Font Test

Test two applications.

Native Wayland:

```text
Firefox
Kitty
native Qt application
```

XWayland:

```text
known X11 application
```

If:

```text
Wayland = sharp
XWayland = blurry
```

the font file is probably not the main problem.

Investigate:

```text
XWayland scaling
application DPI
toolkit scaling
```

---

# 69. GTK Font Rendering

GTK applications normally use Fontconfig/FreeType.

If a particular GTK application ignores your expected font settings:

```bash
fc-match monospace
```

Check the application-specific settings before adding global hacks.

---

# 70. GTK4 Font Rendering

Some GTK4 applications do not honor every legacy Xft setting.

For advanced applications that specifically need manual font metrics:

```bash
mkdir -p ~/.config/gtk-4.0
vim ~/.config/gtk-4.0/settings.ini
```

Example:

```ini
[Settings]
gtk-hint-font-metrics=true
gtk-font-rendering=manual
```

Only add this if the affected GTK4 application actually benefits from it.

---

# 71. Qt Font Rendering

Install:

```bash
pacman -S qt5-wayland qt6-wayland
```

Use:

```text
QT_QPA_PLATFORM=wayland;xcb
```

Test:

```bash
QT_QPA_PLATFORM=wayland qt6ct
```

if `qt6ct` is installed.

Do not globally force:

```text
QT_QPA_PLATFORM=xcb
```

unless an application specifically requires XWayland.

---

# 72. Better GPU Rendering Strategy

The goal is not:

```text
make NVIDIA render everything
```

The goal is:

```text
use the GPU that gives the shortest and most reliable rendering path
```

For Intel-primary hybrid:

```text
Intel
  |
  +-- compositor
  +-- browser
  +-- video decode
  |
  +-- NVIDIA only for selected applications
```

For NVIDIA-primary desktop:

```text
NVIDIA
  |
  +-- compositor
  +-- browser
  +-- games
  +-- GPU applications

Intel
  |
  +-- secondary
```

---

# 73. Application GPU Test

Normal:

```bash
glxinfo -B
```

NVIDIA:

```bash
prime-run glxinfo -B
```

Vulkan:

```bash
vulkaninfo --summary
```

NVIDIA Vulkan:

```bash
prime-run vulkaninfo --summary
```

---

# 74. Browser GPU Verification

Firefox:

```text
about:support
```

Check:

```text
Window Protocol
Compositing
WebRender
```

Chromium/Brave:

Open:

```text
chrome://gpu
```

or:

```text
brave://gpu
```

Check:

```text
Graphics Feature Status
Video Decode
WebGL
Vulkan
```

Do not judge GPU rendering only from `nvidia-smi`.

---

# 75. Do Not Disable Browser Hardware Acceleration

Do not use:

```text
hardware acceleration disabled
```

as the first fix for a GPU problem.

Instead determine:

```text
Which GPU is rendering?
Which GPU is decoding?
Which GPU owns the display?
Is the browser Wayland-native?
```

---

# 76. Install Modern Screenshot Tools

Install:

```bash
pacman -S \
    grim \
    slurp \
    hyprshot \
    wl-clipboard \
    libnotify \
    hyprpicker
```

---

# 77. Screenshot Commands

Full screen:

```bash
grim ~/Pictures/screenshot-$(date +%F-%H%M%S).png
```

Select a region:

```bash
grim -g "$(slurp)" \
    ~/Pictures/screenshot-$(date +%F-%H%M%S).png
```

Hyprshot:

```bash
hyprshot -m region
```

Window:

```bash
hyprshot -m window
```

Monitor:

```bash
hyprshot -m output
```

---

# 78. Modern GPU Screen Recording

Install:

```bash
pacman -S gpu-screen-recorder
```

Check:

```bash
gpu-screen-recorder --help
```

GPU Screen Recorder is a low-overhead Wayland-oriented recorder.

Use it for:

```text
screen recording
game recording
instant replay
```

---

# 79. Hyprpicker

Run:

```bash
hyprpicker
```

Copy a color automatically:

```bash
hyprpicker -a
```

This is useful for:

```text
Waybar themes
Hyprland themes
CSS
UI work
terminal themes
```

---

# 80. Hyprsunset

Install:

```bash
pacman -S hyprsunset
```

Check:

```bash
hyprsunset --help
```

Use it for a Wayland-native blue-light/night filter.

Do not run both:

```text
hyprsunset
gammastep
```

for the same display unless you intentionally want both.

---

# 81. External Monitor Control with ddcutil

Install:

```bash
pacman -S ddcutil
```

Detect monitors:

```bash
ddcutil detect
```

Read capabilities:

```bash
ddcutil capabilities
```

Read brightness:

```bash
ddcutil getvcp 10
```

Set brightness:

```bash
ddcutil setvcp 10 50
```

DDC/CI support depends on the monitor.

---

# 82. Removable Storage Integration

Install:

```bash
pacman -S \
    udisks2 \
    udiskie \
    gvfs \
    gvfs-mtp \
    gvfs-smb \
    gvfs-nfs
```

Use:

```bash
udiskie
```

for automatic removable-drive integration.

---

# 83. GNOME Keyring + libsecret

Install:

```bash
pacman -S \
    gnome-keyring \
    libsecret
```

GNOME Keyring provides:

```text
Secret Service
password storage
SSH key support
application secrets
```

---

## 83.1 Git credential integration

Configure:

```bash
git config --global credential.helper \
    /usr/lib/git-core/git-credential-libsecret
```

---

## 83.2 Verify Secret Service

Check:

```bash
systemctl --user status gnome-keyring-daemon
```

Test:

```bash
secret-tool store \
    --label="Arch test" \
    example test
```

Then:

```bash
secret-tool lookup example test
```

Remove the test secret afterward.

---

# 84. GNOME Keyring + Ly PAM Integration

If Ly does not automatically unlock your login keyring:

Edit:

```bash
sudo vim /etc/pam.d/ly
```

Add:

```text
auth       optional     pam_gnome_keyring.so
session    optional     pam_gnome_keyring.so auto_start
```

Do not blindly replace the existing PAM file.

Add the lines alongside the existing login stack.

WARNING:

A syntax error in PAM configuration can prevent login.

Keep a root shell or installation USB available when modifying PAM.

---

# 85. Wayland Environment

Verify:

```bash
echo "$XDG_SESSION_TYPE"
```

Expected:

```text
wayland
```

Also:

```bash
loginctl show-session "$XDG_SESSION_ID" -p Type
```

Expected:

```text
Type=wayland
```

---

# 86. XDG Current Desktop

Verify:

```bash
echo "$XDG_CURRENT_DESKTOP"
```

Expected:

```text
Hyprland
```

When using UWSM, allow UWSM to manage the session environment instead of forcing conflicting values from multiple files.

---

# 87. Hyprland Lua Configuration

Create:

```bash
mkdir -p ~/.config/hypr
```

Current Hyprland releases provide Lua configuration support.

Create:

```bash
vim ~/.config/hypr/hyprland.lua
```

Do not copy monitor names from another machine.

---

# 88. Basic Hyprland Lua Configuration

Example:

```lua
-- ============================================================
-- Hyprland basic configuration
-- ============================================================

-- ------------------------------------------------------------
-- GPU selection
--
-- Choose ONE profile.
-- Do not enable both.
-- ------------------------------------------------------------

-- NVIDIA primary:
-- hl.env(
--     "AQ_DRM_DEVICES",
--     "/dev/dri/nvidia:/dev/dri/intel"
-- )

-- Intel primary:
-- hl.env(
--     "AQ_DRM_DEVICES",
--     "/dev/dri/intel:/dev/dri/nvidia"
-- )


-- ------------------------------------------------------------
-- XWayland HiDPI
--
-- Prevent compositor-level scaling of XWayland surfaces.
-- The application/toolkit becomes responsible for scaling.
-- This can improve sharpness on fractional scaling displays.
-- ------------------------------------------------------------

hl.config({
    xwayland = {
        force_zero_scaling = true,
    }
})


-- ------------------------------------------------------------
-- Input
-- ------------------------------------------------------------

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
    }
})


-- ------------------------------------------------------------
-- General layout
-- ------------------------------------------------------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        layout = "dwindle",
    }
})


-- ------------------------------------------------------------
-- Decoration
-- ------------------------------------------------------------

hl.config({
    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
        },
    }
})


-- ------------------------------------------------------------
-- Terminal
-- ------------------------------------------------------------

hl.bind(
    "SUPER + RETURN",
    hl.dsp.exec_cmd("kitty")
)


-- ------------------------------------------------------------
-- Launcher
-- ------------------------------------------------------------

hl.bind(
    "SUPER + SPACE",
    hl.dsp.exec_cmd("wofi --show drun")
)


-- ------------------------------------------------------------
-- Close active window
-- ------------------------------------------------------------

hl.bind(
    "SUPER + Q",
    hl.dsp.exec_cmd("hyprctl dispatch killactive")
)


-- ------------------------------------------------------------
-- Reload configuration
-- ------------------------------------------------------------

hl.bind(
    "SUPER + SHIFT + R",
    hl.dsp.exec_cmd("hyprctl reload")
)


-- ------------------------------------------------------------
-- Desktop services
-- ------------------------------------------------------------

hl.on("hyprland.start", function()

    -- Waybar
    hl.exec_cmd("waybar")

    -- Polkit authentication agent
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Wallpaper daemon
    -- Enable after creating hyprpaper.conf.
    -- hl.exec_cmd("hyprpaper")

    -- Idle daemon
    -- Enable after creating hypridle.conf.
    -- hl.exec_cmd("hypridle")

end)
```

When using UWSM, prefer placing session-wide environment variables in:

```text
~/.config/uwsm/env
~/.config/uwsm/env-hyprland
```

instead of duplicating them throughout Hyprland.

---

# 89. UWSM Desktop Entry

Find sessions:

```bash
ls -1 /usr/share/wayland-sessions/
```

You should have something similar to:

```text
hyprland.desktop
```

To make a UWSM-managed session available to the display manager:

```bash
mkdir -p ~/.local/share/wayland-sessions
```

Create:

```bash
vim ~/.local/share/wayland-sessions/hyprland-uwsm.desktop
```

Use:

```ini
[Desktop Entry]
Name=Hyprland (UWSM)
Comment=Hyprland managed by UWSM
Exec=uwsm start -- hyprland.desktop
TryExec=uwsm
Type=Application
DesktopNames=Hyprland
```

If the display manager does not expose user session entries, place the equivalent file under:

```text
/usr/local/share/wayland-sessions/
```

instead.

---

# 90. UWSM Verification

Check:

```bash
uwsm --help
```

Then:

```bash
uwsm select
```

When starting from a compatible login environment:

```bash
uwsm start -- hyprland.desktop
```

Verify user units:

```bash
systemctl --user list-units --type=service
```

Look for:

```text
wayland-wm@...
wayland-session@...
```

---

# 91. UWSM Application Launching

Instead of:

```bash
kitty
```

you can launch through UWSM:

```bash
uwsm app -- kitty
```

For a desktop entry:

```bash
uwsm app -- firefox.desktop
```

This allows applications to become properly managed systemd user units/scopes.

Do not convert every application to UWSM until your basic session is stable.

---

# 92. Waybar

Install:

```bash
pacman -S waybar
```

Start manually:

```bash
waybar
```

When using UWSM, you may eventually create a user service instead of using a compositor autostart command.

For a first installation, either approach is fine.

---

# 93. Hyprpaper

Create:

```bash
mkdir -p ~/.config/hypr
vim ~/.config/hypr/hyprpaper.conf
```

Example:

```text
wallpaper {
    monitor =
    path = /home/USERNAME/Pictures/wallpaper.jpg
    fit_mode = cover
}
```

Replace:

```text
USERNAME
```

and the file path.

---

# 94. Hypridle

Create:

```bash
vim ~/.config/hypr/hypridle.conf
```

Example:

```text
general {
    lock_cmd = pidof hyprlock || hyprlock
}

listener {
    timeout = 300
    on-timeout = loginctl lock-session
}

listener {
    timeout = 600
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

listener {
    timeout = 900
    on-timeout = systemctl suspend
}
```

This gives:

```text
5 min  -> lock
10 min -> display off
15 min -> suspend
```

Adjust to your needs.

---

# 95. Ly Display Manager

Install:

```bash
pacman -S ly
```

---

## 95.1 Enable Ly

Disable the getty on the selected TTY:

```bash
systemctl disable getty@tty2.service
```

Enable Ly:

```bash
systemctl enable ly@tty2.service
```

Verify:

```bash
systemctl is-enabled ly@tty2.service
```

---

# 96. Ly Sessions

List:

```bash
ls -1 /usr/share/wayland-sessions/
```

Examples:

```text
hyprland.desktop
hyprland-uwsm.desktop
```

Ly uses the session names from these files.

Restart Ly after adding a new session:

```bash
sudo systemctl restart ly@tty2.service
```

or simply reboot.

---

# 97. Ly Automatic Login

Edit:

```bash
sudo vim /etc/ly/config.ini
```

Set:

```ini
auto_login_service = ly-autologin
auto_login_user = YOUR_USERNAME
auto_login_session = hyprland
```

For UWSM:

```ini
auto_login_session = hyprland-uwsm
```

Use exactly the session name shown by the installed desktop entry.

IMPORTANT:

Automatic login means the computer can enter the desktop without a password.

Use it only when physical-access security permits it.

---

# 98. Optional zram

zram creates compressed swap in RAM.

Install:

```bash
sudo pacman -S zram-generator
```

Create:

```bash
sudo vim /etc/systemd/zram-generator.conf
```

Simple configuration:

```ini
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
```

Apply after reboot.

Verify:

```bash
swapon --show
```

Example:

```text
NAME       TYPE      SIZE
/dev/zram0 partition 16G
```

Do not create both a very large disk swap and huge zram unless you understand the intended memory behavior.

---

# 99. Swap and Hibernation

zram alone is not a normal persistent hibernation target.

For hibernation:

```text
persistent disk swap
+
resume configuration
+
appropriate initramfs support
```

are required.

If you want hibernation, design it separately.

---

# 100. Firewall

Install:

```bash
sudo pacman -S ufw
```

Check current rules:

```bash
sudo ufw status verbose
```

Set defaults:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

If SSH is required:

```bash
sudo ufw limit ssh
```

Then enable:

```bash
sudo ufw enable
```

Check:

```bash
sudo ufw status numbered
```

---

# 101. Firewall + Docker

Docker can install its own firewall/NAT rules.

Therefore:

```text
UFW alone does not necessarily protect Docker-published ports.
```

This is important.

---

## 101.1 Safest development pattern

When possible, bind development containers only to localhost:

```yaml
ports:
  - "127.0.0.1:8080:8080"
```

instead of:

```yaml
ports:
  - "8080:8080"
```

The first means:

```text
host localhost only
```

The second may expose the service to the LAN depending on firewall/routing.

---

## 101.2 ufw-docker

If you need Docker containers exposed while still integrating the firewall:

Install the AUR package manually:

```bash
git clone https://aur.archlinux.org/ufw-docker.git
cd ufw-docker
makepkg -si
```

Then inspect the package before installing it.

After installation:

```bash
sudo ufw-docker install
```

Check:

```bash
sudo ufw-docker help
```

This is an advanced firewall configuration.

Do not assume:

```text
ufw enable
```

automatically secures every Docker-published port.

---

# 102. Docker

Install:

```bash
sudo pacman -S docker
```

Enable:

```bash
sudo systemctl enable --now docker.service
```

Add user:

```bash
sudo usermod -aG docker "$USER"
```

Log out and log back in.

WARNING:

Membership in:

```text
docker
```

provides effectively root-equivalent control over the machine.

---

# 103. Optional Btrfs + Snapper

The main guide prefers:

```text
ext4
```

Btrfs is an optional advanced profile.

Use Btrfs when you specifically want:

```text
snapshots
rollback
pre-update snapshots
snapshot boot entries
filesystem subvolumes
```

---

# 104. Btrfs Partition Layout

A typical advanced layout:

```text
ESP              1-4+ GiB FAT32
root             remaining Btrfs
```

A Btrfs root can contain:

```text
@
@home
@var
@snapshots
```

The exact subvolume design is a matter of policy.

Do not copy a complex Btrfs layout without understanding snapshot boundaries.

---

# 105. Create Btrfs

Install:

```bash
pacman -S btrfs-progs
```

Format:

```bash
mkfs.btrfs -L arch-root /dev/nvme0n1p2
```

Mount temporarily:

```bash
mount /dev/nvme0n1p2 /mnt
```

Create subvolumes:

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
```

Unmount:

```bash
umount /mnt
```

---

# 106. Mount Btrfs Subvolumes

Example:

```bash
mount \
    -o subvol=@,compress=zstd,noatime \
    /dev/nvme0n1p2 \
    /mnt
```

Create:

```bash
mkdir -p /mnt/home
mkdir -p /mnt/.snapshots
```

Mount:

```bash
mount \
    -o subvol=@home,compress=zstd,noatime \
    /dev/nvme0n1p2 \
    /mnt/home
```

Mount:

```bash
mount \
    -o subvol=@snapshots,compress=zstd,noatime \
    /dev/nvme0n1p2 \
    /mnt/.snapshots
```

---

# 107. Snapper

Install:

```bash
pacman -S snapper
```

Create configuration:

```bash
snapper -c root create-config /
```

Inspect:

```bash
snapper -c root list
```

Create a snapshot:

```bash
sudo snapper -c root create --description "Before GPU configuration"
```

---

# 108. Btrfs Snapshot Recovery

Before an important system change:

```text
snapshot
    |
    v
make changes
    |
    +-- works
    |
    +-- fails
           |
           v
       restore snapshot
```

Remember:

```text
snapshot != backup
```

A snapshot stored on the same physical disk does not protect against:

```text
disk failure
controller failure
fire
theft
```

---

# 109. Limine + Snapper

Limine can integrate with Snapper through:

```text
limine-snapper-sync
```

This is one reason Limine is especially interesting for the advanced Btrfs profile.

Install:

```bash
# AUR package:
limine-snapper-sync
```

Install it using your normal unprivileged AUR workflow.

Then configure:

```text
Limine
+
Snapper
+
snapshot boot entries
```

Do not add this to an ext4 installation.

---

# 110. Snapshot ESP Size

For a simple ext4 installation:

```text
1 GiB ESP
```

is sufficient for ordinary kernel/bootloader usage.

For:

```text
Btrfs
+
many bootable snapshots
+
multiple kernels
+
large early-boot modules
+
NVIDIA
```

a larger ESP may be useful.

Do not blindly create dozens of snapshots on a small ESP.

Monitor:

```bash
df -h /boot
```

---

# 111. Final Package Bundle

A reasonable modern Hyprland baseline:

```bash
sudo pacman -S \
    hyprland \
    xorg-xwayland \
    wayland \
    wayland-protocols \
    wl-clipboard \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland \
    kitty \
    waybar \
    wofi \
    hyprpaper \
    hypridle \
    hyprlock \
    hyprcursor \
    hyprpicker \
    hyprsunset \
    grim \
    slurp \
    hyprshot \
    gpu-screen-recorder \
    ddcutil \
    udiskie \
    udisks2 \
    gvfs \
    gvfs-mtp \
    gvfs-smb \
    gvfs-nfs \
    gnome-keyring \
    libsecret \
    inter-font \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji \
    polkit \
    hyprpolkitagent \
    pipewire \
    pipewire-audio \
    pipewire-alsa \
    pipewire-pulse \
    wireplumber \
    bluez \
    bluez-utils \
    blueman \
    network-manager-applet \
    btop \
    fastfetch \
    ripgrep \
    fd \
    fzf \
    rsync \
    unzip \
    zip \
    7zip
```

---

# 112. Graphics Package Bundle

Intel:

```bash
sudo pacman -S \
    mesa \
    vulkan-intel \
    intel-media-driver \
    libva-utils \
    vulkan-tools
```

NVIDIA:

```bash
sudo pacman -S \
    nvidia-open \
    nvidia-utils \
    nvidia-prime \
    egl-wayland \
    mesa-utils
```

Optional NVIDIA 32-bit:

```bash
sudo pacman -S lib32-nvidia-utils
```

Optional NVIDIA VA-API:

```bash
sudo pacman -S libva-nvidia-driver
```

Only install the last package if you actually need the NVIDIA VA-API path.

---

# 113. Network Package Bundle

```bash
sudo pacman -S \
    networkmanager \
    network-manager-applet
```

systemd-resolved is part of the systemd installation.

---

# 114. Security Package Bundle

```bash
sudo pacman -S \
    polkit \
    hyprpolkitagent \
    ufw \
    kernel-modules-hook
```

Optional:

```bash
sudo pacman -S apparmor
```

Do not enable security frameworks without learning their policy model first.

---

# 115. Verify Kernel

```bash
uname -r
```

---

# 116. Verify CPU Microcode

```bash
journalctl -k | grep -i microcode
```

---

# 117. Verify Intel GPU

```bash
lspci -k | grep -A3 -i Intel
```

---

# 118. Verify NVIDIA

```bash
nvidia-smi
```

---

# 119. Verify NVIDIA DRM

```bash
cat /sys/module/nvidia_drm/parameters/modeset
```

Expected:

```text
Y
```

---

# 120. Verify GPU Paths

```bash
ls -l /dev/dri/by-path/
```

If stable names were created:

```bash
ls -l /dev/dri/intel
ls -l /dev/dri/nvidia
```

---

# 121. Verify Vulkan

Intel/default:

```bash
vulkaninfo --summary
```

NVIDIA:

```bash
prime-run vulkaninfo --summary
```

---

# 122. Verify OpenGL

Default:

```bash
glxinfo -B
```

NVIDIA offload:

```bash
prime-run glxinfo -B
```

---

# 123. Verify VA-API

Intel:

```bash
vainfo
```

If you intentionally configured NVIDIA VA-API:

```bash
LIBVA_DRIVER_NAME=nvidia vainfo
```

Do not export this globally on Intel-primary systems without a reason.

---

# 124. Verify Wayland

```bash
echo "$XDG_SESSION_TYPE"
```

Expected:

```text
wayland
```

---

# 125. Verify Hyprland

```bash
hyprctl version
```

Check monitors:

```bash
hyprctl monitors
```

Check input devices:

```bash
hyprctl devices
```

Check config errors:

```bash
hyprctl configerrors
```

---

# 126. Verify PipeWire

```bash
systemctl --user status pipewire
systemctl --user status pipewire-pulse
systemctl --user status wireplumber
```

Audio devices:

```bash
wpctl status
```

---

# 127. Verify NetworkManager

```bash
systemctl status NetworkManager
```

```bash
nmcli device status
```

---

# 128. Verify systemd-resolved

```bash
systemctl status systemd-resolved
```

```bash
resolvectl status
```

---

# 129. Verify Polkit

```bash
systemctl --user status hyprpolkitagent
```

Check processes:

```bash
pgrep -af polkit
```

Avoid multiple authentication agents.

---

# 130. Verify UWSM

```bash
uwsm --help
```

Then inside the session:

```bash
systemctl --user list-units --type=target
```

and:

```bash
systemctl --user list-units --type=service
```

---

# 131. Verify Fonts

```bash
fc-match sans-serif
```

```bash
fc-match monospace
```

```bash
fc-match Inter
```

```bash
fc-match "JetBrains Mono"
```

---

# 132. Verify Font Cache

```bash
fc-cache -fv
```

---

# 133. Verify XWayland Rendering

Identify an XWayland application.

Then inspect:

```bash
hyprctl clients
```

Compare it against native Wayland applications.

If the XWayland application is blurry while native Wayland applications are sharp:

```text
do not change the font first
```

Investigate:

```text
force_zero_scaling
application DPI
toolkit scaling
```

---

# 134. Verify Electron Rendering

For Electron applications:

```text
check whether the application uses Wayland
```

Use:

```bash
ps aux | grep -i electron
```

or application-specific debugging information.

For applications requiring a launch flag:

```text
--ozone-platform=wayland
```

---

# 135. Verify Browser Rendering

Firefox:

```text
about:support
```

Check:

```text
Window Protocol: wayland
```

Brave/Chromium:

```text
brave://gpu
```

Check:

```text
Compositing
WebGL
Video Decode
Vulkan
```

---

# 136. Troubleshooting NVIDIA + Intel

## 136.1 Hyprland starts on wrong GPU

Check:

```bash
ls -l /dev/dri/by-path/
```

Then:

```text
AQ_DRM_DEVICES
```

Example NVIDIA primary:

```bash
export AQ_DRM_DEVICES=/dev/dri/nvidia:/dev/dri/intel
```

Example Intel primary:

```bash
export AQ_DRM_DEVICES=/dev/dri/intel:/dev/dri/nvidia
```

---

## 136.2 Monitor connected to NVIDIA is missing

Make sure NVIDIA is included:

```text
AQ_DRM_DEVICES=/dev/dri/intel:/dev/dri/nvidia
```

The NVIDIA GPU does not necessarily have to be first.

It only needs to be available to Hyprland.

---

## 136.3 Secondary monitor is slow

Hyprland's NVIDIA multi-GPU path can have limitations.

As a troubleshooting option:

```bash
export AQ_FORCE_LINEAR_BLIT=0
```

Only use this if an actual multi-GPU presentation problem exists.

Do not add it to a healthy system.

---

# 137. NVIDIA Browser Video Problems

If Intel is the compositor GPU:

```text
Intel
    |
    +-- Hyprland
    +-- browser
    +-- video decode
```

Do not force:

```text
LIBVA_DRIVER_NAME=nvidia
```

globally.

Check:

```bash
vainfo
```

and:

```bash
nvidia-smi
```

while playing video.

The goal is to avoid unnecessary:

```text
Intel -> NVIDIA -> Intel
```

buffer transfers.

---

# 138. NVIDIA Power Problems

Run:

```bash
nvidia-smi
```

If the system is supposed to leave NVIDIA idle, but it remains active:

```bash
sudo lsof /dev/nvidia*
```

Check for unexpected processes.

---

# 139. NVIDIA Temperature

```bash
nvidia-smi \
    --query-gpu=temperature.gpu,power.draw,utilization.gpu \
    --format=csv
```

If NVIDIA is the primary desktop GPU, some idle power is expected.

If the monitor is Intel-primary and NVIDIA is meant to sleep, an unexpected process keeping `/dev/nvidia*` open deserves investigation.

---

# 140. Font Troubleshooting Sequence

If text looks blurry:

```text
1. Verify Wayland
2. Verify native application backend
3. Verify monitor scale
4. Verify XWayland status
5. Enable force_zero_scaling
6. Verify Fontconfig
7. Verify FreeType
8. Check application-specific scaling
9. Only then adjust font rendering parameters
```

Do not change all settings at once.

---

# 141. NVIDIA Troubleshooting Sequence

If graphics are broken:

```text
1. nvidia-smi
2. lspci -k
3. /sys/module/nvidia_drm/parameters/modeset
4. /dev/dri/by-path/
5. AQ_DRM_DEVICES
6. hyprctl monitors
7. journalctl -b -k
8. Hyprland logs
```

Only after these checks consider:

```text
early KMS
AQ_FORCE_LINEAR_BLIT
kernel parameters
driver branch changes
```

---

# 142. Hyprland Logs

```bash
journalctl --user -b | \
    grep -Ei 'hypr|aquamarine|wayland|drm|nvidia|i915'
```

Kernel:

```bash
journalctl -b -k | \
    grep -Ei 'nvidia|nvrm|drm|i915|firmware'
```

---

# 143. Ly Logs

```bash
sudo journalctl -u ly@tty2.service -b
```

System log:

```bash
sudo less /var/log/ly.log
```

Session log:

```bash
less ~/.local/state/ly-session.log
```

---

# 144. Audio Troubleshooting

```bash
wpctl status
```

Then:

```bash
systemctl --user status pipewire
systemctl --user status pipewire-pulse
systemctl --user status wireplumber
```

Restart:

```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

---

# 145. DNS Troubleshooting

Check:

```bash
resolvectl status
```

Check:

```bash
resolvectl dns
```

Check:

```bash
readlink -f /etc/resolv.conf
```

Expected:

```text
/run/systemd/resolve/stub-resolv.conf
```

Check:

```bash
nmcli general status
```

---

# 146. Firewall Verification

```bash
sudo ufw status verbose
```

See rules:

```bash
sudo ufw status numbered
```

Check firewall backend state:

```bash
sudo nft list ruleset
```

If Docker is installed:

```bash
sudo iptables -S
```

and:

```bash
sudo iptables -t nat -S
```

---

# 147. Pacman Updates

Normal update:

```bash
sudo pacman -Syu
```

Do not normally use:

```bash
sudo pacman -Sy
```

Do not perform partial upgrades.

Avoid:

```bash
sudo pacman -Syyu
```

unless you have a specific mirror/database problem that actually requires refreshing all repository databases.

---

# 148. AUR Safety

Do not build AUR packages as root.

Correct:

```bash
git clone ...
cd package
makepkg -si
```

Incorrect:

```bash
sudo makepkg
```

Inspect:

```text
PKGBUILD
sources
install scripts
dependencies
```

before installing an AUR package.

---

# 149. Optional Common Utilities

```bash
sudo pacman -S \
    btop \
    fastfetch \
    tree \
    ripgrep \
    fd \
    fzf \
    jq \
    curl \
    wget \
    less \
    tmux \
    unzip \
    zip \
    7zip \
    rsync
```

---

# 150. Optional File Manager

```bash
sudo pacman -S thunar
```

Optional:

```bash
sudo pacman -S \
    tumbler \
    file-roller
```

---

# 151. Optional Multimedia

Basic:

```bash
sudo pacman -S \
    ffmpeg \
    gst-libav
```

Do not install a gigantic multimedia dependency set just because another distro does.

Install application-specific codecs only when needed.

---

# 152. Optional Printing

```bash
sudo pacman -S cups
```

Enable:

```bash
sudo systemctl enable --now cups.service
```

---

# 153. Optional SSH

Install:

```bash
sudo pacman -S openssh
```

Enable only if remote SSH access is wanted:

```bash
sudo systemctl enable --now sshd.service
```

If UFW is active:

```bash
sudo ufw limit ssh
```

---

# 154. Optional Development

Rust:

```bash
sudo pacman -S rustup
rustup default stable
```

C/C++:

```bash
sudo pacman -S \
    gcc \
    clang \
    lldb \
    cmake
```

---

# 155. Optional Docker

```bash
sudo pacman -S docker
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$USER"
```

Log out and log in again.

Then:

```bash
docker info
```

---

# 156. Optional Container Alternative

Podman can be used instead of Docker:

```bash
sudo pacman -S podman
```

Do not install both unless you need both.

---

# 157. Final Service Architecture

## 157.1 System services

Recommended:

```text
NetworkManager.service
systemd-resolved.service
systemd-timesyncd.service
ly@tty2.service
bluetooth.service
```

Optional:

```text
cups.service
sshd.service
docker.service
```

---

## 157.2 User services

Typical:

```text
pipewire
pipewire-pulse
wireplumber
gnome-keyring-daemon
hyprpolkitagent
```

UWSM adds:

```text
graphical-session
wayland-session
Hyprland user units
application user units
```

---

# 158. Final GPU Architecture Profiles

## 158.1 Desktop NVIDIA-primary profile

Use when:

```text
Monitor connected to NVIDIA
```

Configuration:

```text
AQ_DRM_DEVICES=/dev/dri/nvidia:/dev/dri/intel
```

Result:

```text
NVIDIA
    |
    +-- Hyprland
    +-- Waybar
    +-- browser
    +-- games
    +-- GPU applications

Intel
    |
    +-- secondary
```

---

## 158.2 Intel-primary hybrid profile

Use when:

```text
Monitor connected to Intel
NVIDIA is secondary/offload
```

Configuration:

```text
AQ_DRM_DEVICES=/dev/dri/intel:/dev/dri/nvidia
```

Result:

```text
Intel
    |
    +-- Hyprland
    +-- browser
    +-- video decode

NVIDIA
    |
    +-- prime-run applications
```

---

# 159. Final Rendering Architecture

The ideal rendering path is:

```text
Native Wayland application
        |
        v
Wayland surface
        |
        v
Hyprland
        |
        v
Primary GPU
        |
        v
Monitor
```

Avoid:

```text
Application
    |
    v
XWayland
    |
    v
compositor fractional resampling
    |
    v
blurry text
```

For unavoidable XWayland applications:

```text
force_zero_scaling
+
application-native DPI
```

is preferred.

---

# 160. Final Font Rendering Architecture

```text
Inter / JetBrains Mono / Noto
             |
             v
         Fontconfig
             |
             v
          FreeType
             |
      +------+------+
      |             |
   GTK/Wayland    Qt/Wayland
      |             |
      +------+------+
             |
             v
          Hyprland
             |
             v
          Display
```

For XWayland applications:

```text
XWayland
    |
    +-- force_zero_scaling
    |
    +-- toolkit scaling
```

---

# 161. Final Performance Rules

```text
1. Keep the compositor on one primary GPU.

2. Include every GPU that owns a connected monitor in AQ_DRM_DEVICES.

3. Use PRIME render offload instead of globally forcing NVIDIA
   on Intel-primary hybrid systems.

4. Do not globally set LIBVA_DRIVER_NAME=nvidia on Intel-primary systems.

5. Prefer native Wayland applications.

6. Avoid unnecessary XWayland scaling.

7. Use force_zero_scaling when XWayland applications are blurry.

8. Do not globally use GDK_SCALE=2 on fractional-scaling systems.

9. Keep FreeType defaults unless testing demonstrates that a change helps.

10. Use Fontconfig rather than application-by-application hacks where possible.

11. Do not use old Infinality font configurations.

12. Use hardware video decoding on the GPU already doing the display
    composition whenever possible.

13. Do not install CUDA just because an NVIDIA graphics driver is installed.

14. Do not use nvidia-persistenced unless a workload actually requires it.

15. Do not add ibt=off without evidence.

16. Do not force nvidia-drm.modeset=1 on modern drivers without a reason.

17. Early NVIDIA KMS is optional and has hibernation implications.

18. Use kernel-modules-hook on systems where kernel/module recovery matters.

19. Keep the installed package set intentional.

20. Measure GPU behavior with:
       nvidia-smi
       glxinfo -B
       vulkaninfo --summary
       vainfo
       hyprctl monitors

21. Measure font problems by comparing native Wayland and XWayland apps.

22. Do not change GPU, scaling, fontconfig and toolkit variables
    simultaneously when debugging.
```

---

# 162. Final Verification Checklist

## 162.1 UEFI

```bash
test -d /sys/firmware/efi/efivars && echo UEFI
```

---

## 162.2 Bootloader

systemd-boot:

```bash
bootctl status
```

GRUB:

```bash
efibootmgr -v
```

Limine:

```bash
limine-list
```

---

## 162.3 Kernel

```bash
uname -r
```

---

## 162.4 Intel

```bash
lspci -k | grep -A3 -i Intel
```

Expected:

```text
i915
```

---

## 162.5 NVIDIA

```bash
nvidia-smi
```

---

## 162.6 NVIDIA DRM

```bash
cat /sys/module/nvidia_drm/parameters/modeset
```

Expected:

```text
Y
```

---

## 162.7 DRM Paths

```bash
ls -l /dev/dri/by-path/
```

---

## 162.8 Vulkan

```bash
vulkaninfo --summary
```

and:

```bash
prime-run vulkaninfo --summary
```

---

## 162.9 OpenGL

```bash
glxinfo -B
```

and:

```bash
prime-run glxinfo -B
```

---

## 162.10 VA-API

```bash
vainfo
```

---

## 162.11 Wayland

```bash
echo "$XDG_SESSION_TYPE"
```

Expected:

```text
wayland
```

---

## 162.12 Hyprland

```bash
hyprctl version
```

```bash
hyprctl monitors
```

```bash
hyprctl devices
```

```bash
hyprctl configerrors
```

---

## 162.13 UWSM

```bash
uwsm --help
```

---

## 162.14 Audio

```bash
wpctl status
```

---

## 162.15 Network

```bash
nmcli device status
```

---

## 162.16 DNS

```bash
resolvectl status
```

---

## 162.17 Polkit

```bash
systemctl --user status hyprpolkitagent
```

---

## 162.18 Fonts

```bash
fc-match Inter
fc-match "JetBrains Mono"
fc-match monospace
```

---

## 162.19 Firewall

```bash
sudo ufw status verbose
```

---

## 162.20 zram

```bash
swapon --show
```

---

# 163. Recommended Final Installation Profiles

## 163.1 Profile A — Simple Modern

Use:

```text
UEFI
GPT
ESP
ext4
systemd-boot
NetworkManager
systemd-resolved
Intel + NVIDIA
Hyprland
PipeWire
Polkit
Hyprpolkitagent
Waybar
Ly
Fontconfig
UWSM optional
```

---

## 163.2 Profile B — Performance Desktop

Use:

```text
Profile A
+
nvidia-open
+
Intel media driver
+
stable GPU paths
+
AQ_DRM_DEVICES
+
native Wayland environment
+
XWayland force_zero_scaling
+
Nerd Fonts
+
zram
+
kernel-modules-hook
+
grim/slurp/hyprshot
+
gpu-screen-recorder
+
hyprpicker
+
hyprsunset
+
ddcutil
+
udiskie/GVFS
+
GNOME Keyring/libsecret
+
UFW
```

---

## 163.3 Profile C — Advanced Recovery

Use:

```text
Btrfs
+
Snapper
+
Limine
+
snapshot boot entries
+
kernel recovery strategy
+
optional UKI
+
optional Secure Boot
```

This profile is intentionally separate from the default ext4 installation.

---

# 164. Recommended Choice for a Modern Intel + NVIDIA Desktop

For a normal desktop with a powerful NVIDIA GPU and external monitor:

```text
Filesystem:
    ext4

Bootloader:
    systemd-boot or Limine

GPU:
    NVIDIA primary
    Intel secondary

Driver:
    nvidia-open

Rendering:
    native Wayland

Offload:
    PRIME available

Compositor:
    Hyprland

Session:
    Ly
    UWSM optional

Audio:
    PipeWire + WirePlumber

Network:
    NetworkManager + systemd-resolved

Authentication:
    polkit + hyprpolkitagent

Memory:
    zram optional

Security:
    UFW

Kernel resilience:
    kernel-modules-hook

Fonts:
    Inter
    JetBrains Mono Nerd
    Noto
    Fontconfig + FreeType

Screenshots:
    grim
    slurp
    hyprshot

Recording:
    gpu-screen-recorder

Monitor:
    ddcutil

Storage:
    udiskie + GVFS
```

---

# 165. The Final Mental Model

The finished machine should look like:

```text
                         UEFI
                          |
                          v
                    Bootloader
               /       |        \
       systemd-boot   GRUB      Limine
               \       |        /
                        |
                        v
                       Linux
                        |
          +-------------+-------------+
          |                           |
       Intel                       NVIDIA
          |                           |
       i915                       nvidia-open
          |                           |
       Mesa                         Vulkan
          |                           |
       VA-API                      PRIME
          |                           |
          +-------------+-------------+
                        |
                        v
                     Wayland
                        |
                        v
                    Hyprland
                        |
             +----------+----------+
             |          |          |
           UWSM      XWayland    Portals
             |          |          |
             |          |          |
             +----------+----------+
                        |
             +----------+----------+
             |          |          |
          Waybar      Kitty      Apps
                        |
            +-----------+-----------+
            |                       |
       Native Wayland          XWayland
            |                       |
          Sharp                 zero-scaling
            |                       |
            +-----------+-----------+
                        |
                        v
                    Fontconfig
                        |
                        v
                     FreeType
                        |
                        v
                     Display
```

# 166. The Most Important Configuration Rules

```text
UEFI + GPT
    yes

ext4
    default

Btrfs + Snapper
    optional advanced

systemd-boot
    simple modern option

GRUB
    traditional option

Limine
    advanced/snapshot-oriented option

NetworkManager
    yes

systemd-resolved
    yes

dhcpcd
    no

systemd-timesyncd
    yes

PipeWire + WirePlumber
    yes

polkit
    keep installed

hyprpolkitagent
    graphical authentication agent

nvidia-open
    modern NVIDIA default

nvidia-drm.modeset=1
    normally unnecessary on modern drivers

ibt=off
    troubleshooting only

nvidia-open-dkms
    custom/multiple kernels, not "faster"

Intel i915
    Intel graphics driver

AQ_DRM_DEVICES
    explicit GPU ordering

prime-run
    NVIDIA render offload

LIBVA_DRIVER_NAME=nvidia
    do NOT set globally on Intel-primary hybrid systems

GDK_BACKEND
    prefer Wayland with X11 fallback

QT_QPA_PLATFORM
    Wayland first, X11 fallback

MOZ_ENABLE_WAYLAND
    harmless compatibility setting; modern Firefox is already Wayland-native

Electron
    prefer --ozone-platform=wayland for applications that need it

force_zero_scaling
    useful for XWayland HiDPI

GDK_SCALE=2
    do not use globally on fractional scaling displays

Fontconfig
    central font selection

FreeType
    keep sane defaults first

Nerd Fonts
    recommended for terminal/UI glyphs

zram
    optional

UFW
    recommended firewall

Docker
    requires special firewall consideration

kernel-modules-hook
    recommended rolling-kernel protection

grim + slurp + hyprshot
    screenshot stack

gpu-screen-recorder
    modern recording

hyprpicker
    color picker

hyprsunset
    Wayland-native night filter

ddcutil
    external monitor control

udiskie + GVFS
    removable/network storage integration

gnome-keyring + libsecret
    desktop secret storage

UWSM
    advanced session-management option

Btrfs + Snapper
    advanced recovery option

Omarchy packages
    inspiration, not a dependency list
```

# 167. Reboot

When the installation is complete:

```bash
exit
```

Unmount:

```bash
umount -R /mnt
```

Then:

```bash
reboot
```

Remove the installation USB.

Boot into the installed system.

Run the verification commands in this guide before making large configuration changes.

---

# 168. First Tasks After Successful Boot

Run:

```bash
sudo pacman -Syu
```

Then verify:

```bash
nvidia-smi
```

```bash
ls -l /dev/dri/by-path/
```

```bash
hyprctl monitors
```

```bash
wpctl status
```

```bash
resolvectl status
```

```bash
fc-match monospace
```

```bash
echo "$XDG_SESSION_TYPE"
```

Finally:

```bash
glxinfo -B
prime-run glxinfo -B
vulkaninfo --summary
prime-run vulkaninfo --summary
```

At this point the base platform should be stable.

Only after this stage should you begin tuning:

```text
Hyprland appearance
fonts
GPU selection
Waybar
keybindings
power
applications
development tools
AUR packages
```
