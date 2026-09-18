# Modern Arch Linux + Hyprland Installation Guide

This guide installs a modern, maintainable Arch Linux desktop with:

- UEFI and GPT
- a 2 GiB EFI System Partition (ESP) mounted at `/boot`
- Btrfs with separate `@`, `@home`, `@pkg`, `@log`, and `@swap` subvolumes
- the official Arch kernel and CPU microcode
- unified kernel images (UKIs) booted by `systemd-boot`
- NetworkManager with `systemd-resolved`
- Intel and modern NVIDIA graphics support, including hybrid (Intel + NVIDIA) systems
- a deliberate font-rendering and fractional-scaling policy
- Hyprland managed by UWSM and launched by SDDM
- PipeWire and WirePlumber
- XDG desktop portals, polkit, GNOME Keyring, and common Wayland utilities
- optional zram, hibernation, firewall, snapshots, and containers

The architecture is informed by a working Omarchy system, but this is a normal Arch installation. It deliberately avoids Omarchy-specific packages, repositories, and scripts. Hyprland itself uses its current upstream Lua configuration format.

> **Data-loss warning:** partitioning and formatting commands destroy data. Back up important files, identify the target disk carefully, and replace every example device path with the correct path for your machine.

---

## 1. Scope and design decisions

### 1.1 Main installation path

The main path is intentionally opinionated:

```text
UEFI firmware
  └─ GPT disk
      ├─ 2 GiB FAT32 ESP mounted at /boot
      └─ Btrfs system partition
          ├─ @      → /
          ├─ @home  → /home
          ├─ @pkg   → /var/cache/pacman/pkg
          ├─ @log   → /var/log
          └─ @swap  → /swap

systemd-boot
  └─ unified kernel image
      └─ Linux + initramfs + microcode + kernel command line

SDDM
  └─ Hyprland UWSM session
      ├─ Hyprland
      ├─ systemd user session
      ├─ PipeWire + WirePlumber
      ├─ XDG portals
      └─ graphical applications
```

### 1.2 Why these choices?

- **Btrfs subvolumes** provide compression and useful snapshot boundaries without separate partitions.
- **A 2 GiB ESP** leaves room for multiple UKIs, fallback images, and large NVIDIA initramfs modules.
- **UKIs** keep the kernel, initramfs, microcode, and command line together as one EFI executable.
- **`systemd-boot`** is simple, official, and integrates directly with UKIs.
- **UWSM** gives Hyprland a well-defined systemd user-session lifecycle and environment.
- **SDDM** can select the packaged `Hyprland (uwsm-managed)` session without a custom launcher.
- **Native Wayland** is preferred; XWayland remains available for legacy applications.

### 1.3 What this guide does not cover

These require separate threat-model or hardware decisions:

- full-disk encryption and TPM unlocking
- Secure Boot key enrollment and UKI signing
- BIOS/legacy boot
- RAID, LVM, Intel RST, and Intel VMD migration
- Windows partition resizing
- custom kernels

Do not improvise encryption or Secure Boot halfway through this procedure. Design them before partitioning.

---

## 2. Before booting the installer

### 2.1 Firmware settings

Use:

```text
Boot mode:       UEFI
Partition style: GPT
CSM/Legacy:      disabled
Secure Boot:     disabled for the initial installation
```

If you want both Intel and NVIDIA GPUs visible, enable the integrated GPU or an equivalent `iGPU Multi-Monitor` firmware option.

If the Arch ISO cannot see an NVMe disk, inspect Intel VMD/RST/RAID settings. Do not change the storage-controller mode blindly on a machine that already boots Windows.

### 2.2 Create the installation USB

Download the current Arch ISO and verify its signature or checksum using the instructions on the official Arch download page.

On Linux, identify the USB device:

```bash
lsblk -o NAME,PATH,SIZE,MODEL,TRAN,MOUNTPOINTS
```

Unmount its mounted partitions, then write the ISO to the **whole USB device**, not a partition:

```bash
sudo dd if=archlinux-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace `/dev/sdX`. Selecting the wrong device destroys its contents.

---

## 3. Live ISO phase

All commands in this section run as `root` in the Arch ISO.

### 3.1 Verify UEFI mode

```bash
test -d /sys/firmware/efi/efivars \
  && echo "UEFI mode detected" \
  || echo "ERROR: reboot the ISO in UEFI mode"
```

Do not continue with this guide if UEFI mode was not detected.

### 3.2 Set the console keyboard layout

List available layouts:

```bash
localectl list-keymaps
```

Example:

```bash
loadkeys us
```

### 3.3 Connect to the network

Ethernet normally works automatically. Test it:

```bash
ping -c 3 archlinux.org
```

For Wi-Fi:

```bash
iwctl
```

Inside `iwctl`:

```text
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect YOUR_SSID
exit
```

Replace `wlan0` and `YOUR_SSID`.

### 3.4 Synchronize the clock

```bash
timedatectl set-ntp true
timedatectl status
```

### 3.5 Identify the installation disk

```bash
lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,FSVER,LABEL,MODEL,MOUNTPOINTS
```

The examples below use:

```text
Disk: /dev/nvme0n1
ESP:  /dev/nvme0n1p1
Root: /dev/nvme0n1p2
```

SATA and USB disks usually use names such as `/dev/sda`, `/dev/sda1`, and `/dev/sda2`.

---

## 4. Partition the disk

### 4.1 Recommended layout

```text
Partition 1   2 GiB       EFI System          FAT32
Partition 2   remaining   Linux filesystem    Btrfs
```

A 1 GiB ESP may work, but 2 GiB is a safer default for two UKIs and early NVIDIA modules.

### 4.2 Create the partitions

```bash
cfdisk /dev/nvme0n1
```

Select GPT, create the two partitions, set partition 1 to `EFI System`, write the table, and quit.

Verify before formatting:

```bash
lsblk -o NAME,PATH,SIZE,TYPE,FSTYPE,PARTTYPENAME /dev/nvme0n1
```

### 4.3 Existing Windows installation

If dual booting:

- do not format the Microsoft ESP;
- do not delete Microsoft reserved or recovery partitions;
- reuse an existing ESP only if it has enough free space for the UKIs;
- mount that ESP at `/mnt/boot` later.

This guide does not cover shrinking Windows partitions.

---

## 5. Format and mount Btrfs

### 5.1 Format the new partitions

Only format an ESP you intentionally created for this installation:

```bash
mkfs.fat -F 32 -n EFI /dev/nvme0n1p1
mkfs.btrfs -f -L arch-root /dev/nvme0n1p2
```

### 5.2 Create the subvolumes

```bash
mount /dev/nvme0n1p2 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@swap

umount /mnt
```

Why separate `@pkg` and `@log`?

- package caches do not need to roll back with the root filesystem;
- logs should survive a root rollback so failed boots remain diagnosable;
- an active Btrfs swapfile must not live inside the root snapshot boundary.

### 5.3 Mount the final layout

Use one consistent option set:

```bash
mount -o subvol=@,compress=zstd:3,discard=async /dev/nvme0n1p2 /mnt

mkdir -p /mnt/{boot,home,swap,var/cache/pacman/pkg,var/log}

mount -o subvol=@home,compress=zstd:3,discard=async \
  /dev/nvme0n1p2 /mnt/home

mount -o subvol=@pkg,compress=zstd:3,discard=async \
  /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg

mount -o subvol=@log,compress=zstd:3,discard=async \
  /dev/nvme0n1p2 /mnt/var/log

mount -o subvol=@swap,noatime,nodatacow \
  /dev/nvme0n1p2 /mnt/swap

mount -o fmask=0077,dmask=0077 /dev/nvme0n1p1 /mnt/boot
```

`discard=async` is appropriate for modern SSDs. For rotational disks, omit it.

Verify every mount before installing:

```bash
findmnt -R /mnt
```

---

## 6. Bootstrap Arch

### 6.1 Install the base system

For an Intel CPU:

```bash
pacstrap -K /mnt \
  base base-devel \
  linux linux-headers linux-firmware intel-ucode \
  btrfs-progs dosfstools efibootmgr \
  networkmanager sudo git vim man-db pciutils
```

For an AMD CPU, replace `intel-ucode` with `amd-ucode`.

`linux-headers` is not required by the normal kernel itself, but keeping the matching headers installed is useful when DKMS modules are added.

### 6.2 Generate `fstab`

Run this **after** `pacstrap`, because `/mnt/etc` now exists:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Inspect it:

```bash
sed -n '1,240p' /mnt/etc/fstab
```

Confirm entries exist for:

- `/`
- `/home`
- `/var/cache/pacman/pkg`
- `/var/log`
- `/swap`
- `/boot`

Remove accidental duplicate entries before continuing.

### 6.3 Enter the installed system

```bash
arch-chroot /mnt
```

All commands in the next sections run as `root` inside the chroot.

---

## 7. Chroot: basic system configuration

### 7.1 Time zone and hardware clock

Replace the zone with your own:

```bash
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
```

Enable network time synchronization for the installed system:

```bash
systemctl enable systemd-timesyncd.service
```

### 7.2 Locale

Uncomment the locales you need in `/etc/locale.gen`, for example:

```text
en_US.UTF-8 UTF-8
```

Then run:

```bash
locale-gen
printf 'LANG=en_US.UTF-8\n' > /etc/locale.conf
```

### 7.3 Console keyboard

```bash
printf 'KEYMAP=us\n' > /etc/vconsole.conf
```

### 7.4 Hostname and hosts

Choose a hostname:

```bash
printf 'archpc\n' > /etc/hostname
```

Create `/etc/hosts`:

```bash
cat > /etc/hosts <<'EOF'
127.0.0.1 localhost
::1       localhost
127.0.1.1 archpc.localdomain archpc
EOF
```

Keep the hostname in `/etc/hostname` and `/etc/hosts` consistent.

### 7.5 Root password

```bash
passwd
```

### 7.6 Create the regular user

Replace `alice` with the desired user name:

```bash
useradd -m -G wheel -s /bin/bash alice
passwd alice
```

Enable sudo for `wheel` safely:

```bash
EDITOR=vim visudo
```

Uncomment:

```text
%wheel ALL=(ALL:ALL) ALL
```

Do not add the user to `video`, `render`, or `input` unless a specific application demonstrates that it needs nonstandard static group access. Logind and udev normally grant session access dynamically.

---

## 8. Chroot: networking and DNS

This guide uses one network manager and one DNS resolver:

```text
NetworkManager → systemd-resolved → /etc/resolv.conf
```

### 8.1 Configure NetworkManager

```bash
mkdir -p /etc/NetworkManager/conf.d

cat > /etc/NetworkManager/conf.d/20-dns.conf <<'EOF'
[main]
dns=systemd-resolved
EOF
```

### 8.2 Configure the resolver symlink

```bash
ln -sfn ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

### 8.3 Enable services

```bash
systemctl enable NetworkManager.service
systemctl enable systemd-resolved.service
```

Do not also enable `dhcpcd`, `netctl`, or `systemd-networkd` as competing managers.

### 8.4 Optional DNS-over-TLS

Do not hardcode public DNS globally unless that is your intended network policy. VPNs and corporate networks often require per-link DNS.

If you deliberately want opportunistic DNS-over-TLS, create:

```bash
mkdir -p /etc/systemd/resolved.conf.d

cat > /etc/systemd/resolved.conf.d/20-dot.conf <<'EOF'
[Resolve]
DNSOverTLS=opportunistic
EOF
```

Configure specific DNS servers per NetworkManager connection after the first boot with `nmcli` rather than overriding every network globally.

---

## 9. Chroot: graphics drivers

First identify the hardware:

```bash
lspci -nnk | grep -A4 -E 'VGA compatible controller|3D controller|Display controller'
```

Install only the stacks present in the machine.

### 9.1 Intel graphics

For a modern Intel GPU:

```bash
pacman -S mesa vulkan-intel intel-media-driver libva-utils vulkan-tools mesa-utils
```

The normal kernel driver may be `i915` or, on supported newer hardware, `xe`. Do not force one without a hardware-specific reason.

### 9.2 AMD graphics

For AMD instead of Intel:

```bash
pacman -S mesa vulkan-radeon libva-mesa-driver libva-utils vulkan-tools mesa-utils
```

### 9.3 Modern NVIDIA graphics

For supported Turing-and-newer GPUs on the standard `linux` kernel:

```bash
pacman -S \
  nvidia-open nvidia-utils egl-wayland \
  mesa-utils vulkan-tools libva-utils
```

If using a custom kernel or several kernels, use DKMS instead:

```bash
pacman -S \
  nvidia-open-dkms nvidia-utils egl-wayland \
  mesa-utils vulkan-tools libva-utils
```

Keep the matching headers installed for every kernel used with DKMS.

`nvidia-prime` is deliberately **not** in the lists above. It only provides the small `prime-run` wrapper script, which is useful on an Intel-primary hybrid laptop and pointless when NVIDIA already drives the display. Install it only if you actually want that wrapper:

```bash
pacman -S nvidia-prime
```

Section 15.4 shows the equivalent environment variables, so offload works even without this package.

For NVIDIA VA-API video decoding, add the driver only when you intend to use it:

```bash
pacman -S libva-nvidia-driver
```

For Steam, Wine, and other 32-bit applications, enable `[multilib]` in `/etc/pacman.conf`, run `pacman -Syu`, and install the matching 32-bit userspace packages:

```bash
pacman -S lib32-mesa lib32-vulkan-intel lib32-nvidia-utils
```

Adjust that list to the GPUs actually installed.

### 9.4 Hybrid Intel + NVIDIA notes

On a hybrid machine, both GPUs stay available and the compositor renders on one of them.

Decide which case matches the hardware:

```text
Desktop, monitor cable in the NVIDIA card
    → NVIDIA is the primary renderer
    → render offload is unnecessary

Laptop/board routing the panel through Intel
    → Intel is the primary renderer
    → NVIDIA is used per-application via offload
```

To let an idle NVIDIA GPU enter runtime suspend, enable runtime power management with a udev rule:

```bash
cat > /etc/udev/rules.d/80-nvidia-runtime-pm.rules <<'EOF'
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOF
```

This mainly benefits laptops. A desktop whose monitor is attached to NVIDIA keeps that GPU awake by definition.

Dynamic GPU-mode switching tools such as `supergfxctl` and `optimus-manager` are **not** in the official Arch repositories, and the reference system obtained `supergfxctl` from a third-party repository. This guide keeps both GPUs enabled in firmware and selects the renderer in the session instead. Adopt an external switching daemon only if you specifically need to power the dGPU off entirely, and audit its packaging first.

### 9.5 NVIDIA DRM modesetting

Current NVIDIA drivers enable DRM modesetting by default. Do not add `nvidia-drm.modeset=1` blindly.

Verify after the first boot:

```bash
sudo cat /sys/module/nvidia_drm/parameters/modeset
```

Expected:

```text
Y
```

If it is not enabled, diagnose the installed driver and module configuration before adding kernel parameters.

### 9.6 Optional early NVIDIA module loading

For a desktop whose monitor is physically attached to NVIDIA, early module loading can make graphical startup more deterministic:

```bash
mkdir -p /etc/mkinitcpio.conf.d

cat > /etc/mkinitcpio.conf.d/20-nvidia.conf <<'EOF'
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
EOF
```

On hybrid laptops, early loading may increase dGPU activity. Treat it as a hardware-policy decision, not a universal optimization.

---

## 10. Chroot: initramfs and unified kernel images

### 10.1 Use the systemd initramfs path

Edit `/etc/mkinitcpio.conf` and set one authoritative hook list:

```bash
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck)
```

Notes:

- `systemd` replaces the traditional `udev` hook path.
- `microcode` includes the installed CPU microcode in the generated image.
- `kms` includes early graphics support.
- this unencrypted Btrfs layout does not need `encrypt`, `sd-encrypt`, or `lvm2`.

Do not copy this hook list into an encrypted installation without adding the correct encrypted-root design.

### 10.2 Set the kernel command line

Get the Btrfs filesystem UUID:

```bash
blkid -s UUID -o value /dev/nvme0n1p2
```

Create `/etc/kernel/cmdline` with the real UUID:

```text
root=UUID=YOUR-BTRFS-UUID rootflags=subvol=@ rw rootfstype=btrfs
```

Keep the initial command line simple. Add quiet boot, splash, IOMMU, hibernation, or troubleshooting parameters only when they serve a defined purpose.

### 10.3 Configure the mkinitcpio preset for UKIs

Back up the packaged preset:

```bash
cp /etc/mkinitcpio.d/linux.preset /etc/mkinitcpio.d/linux.preset.original
```

Edit `/etc/mkinitcpio.d/linux.preset` to use UKI outputs:

```bash
ALL_kver="/boot/vmlinuz-linux"

PRESETS=('default' 'fallback')

default_uki="/boot/EFI/Linux/arch-linux.efi"

fallback_uki="/boot/EFI/Linux/arch-linux-fallback.efi"
fallback_options="-S autodetect"
```

Do not keep `default_image` or `fallback_image` active in the same preset unless you intentionally want separate initramfs files in addition to UKIs.

Create the output directory and build:

```bash
mkdir -p /boot/EFI/Linux
mkinitcpio -P
```

Verify:

```bash
ls -lh /boot/EFI/Linux/
bootctl kernel-identify /boot/EFI/Linux/arch-linux.efi
```

A kernel or NVIDIA DKMS update must regenerate the UKI successfully. Read pacman hook output instead of ignoring initramfs errors.

---

## 11. Chroot: install systemd-boot

Install the bootloader files to the mounted ESP without attempting to modify firmware variables from the chroot:

```bash
bootctl --variables=no install
```

A firmware entry is created from the live ISO after leaving the chroot in section 14.

Configure `/boot/loader/loader.conf`:

```bash
cat > /boot/loader/loader.conf <<'EOF'
default @saved
timeout 3
console-mode max
editor no
EOF
```

`systemd-boot` discovers UKIs under `/EFI/Linux/` automatically; a separate loader entry is normally unnecessary.

Verify:

```bash
bootctl status
bootctl list
ls -lh /boot/EFI/Linux/
ls -lh /boot/EFI/systemd/systemd-bootx64.efi
```

### 11.1 Bootloader alternatives

Use exactly one primary bootloader.

- **GRUB** is reasonable for complicated multiboot arrangements, but it is not covered by this main path.
- **Limine** is a valid modern option, but the official Arch `limine` package provides the bootloader itself, not Omarchy’s `limine-install`, `limine-update`, or `limine-list` helper workflow. Those helpers came from the Omarchy-repository package `limine-mkinitcpio-hook` on the reference system. Do not copy Omarchy-specific commands into a plain Arch installation unless you intentionally adopt and audit that external packaging.

---

## 12. Chroot: install the Hyprland desktop

### 12.1 Core desktop and session packages

```bash
pacman -S \
  hyprland uwsm sddm \
  xorg-xwayland \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  qt6-wayland \
  polkit hyprpolkitagent \
  pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber \
  gnome-keyring libsecret \
  foot waybar fuzzel \
  hyprpaper hypridle hyprlock hyprpicker hyprsunset \
  wl-clipboard grim slurp \
  xdg-utils xdg-user-dirs \
  udisks2 udiskie gvfs
```

### 12.2 Fonts

Install a complete font set from the official repositories:

```bash
pacman -S \
  ttf-liberation \
  inter-font \
  ttf-jetbrains-mono-nerd \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  woff2-font-awesome
```

What each package is for:

```text
ttf-liberation            metric-compatible default sans/serif/mono
inter-font                modern UI sans option
ttf-jetbrains-mono-nerd   terminal monospace + Nerd Font icon glyphs
noto-fonts                broad Unicode coverage
noto-fonts-cjk            Chinese, Japanese, Korean
noto-fonts-emoji          color emoji
woff2-font-awesome        icon font used by many bars and web UIs
```

The reference system also carried `ttf-jetbrains-mono-nerd-basic` and `ttf-ia-writer`, which came from a third-party repository. The official `ttf-jetbrains-mono-nerd` package replaces the first; the second is optional and unnecessary for correct rendering.

Install extra font families only when a specific document, language, or design needs them. More fonts do not improve rendering quality.

### 12.3 Font rendering policy

This is where most "blurry" or "ugly" font complaints are actually solved.

Arch already ships sane FreeType defaults through symlinks in `/etc/fonts/conf.d/`:

```text
10-yes-antialias.conf        antialiasing enabled
10-hinting-slight.conf       slight hinting (correct for modern fonts)
11-lcdfilter-default.conf    default LCD filter
```

Do not hand-write hinting, antialiasing, or `rgba` subpixel configuration to "fix" fonts. The reference Omarchy system left all three defaults untouched and changed only font *selection*. Aggressive hinting or full RGBA subpixel rendering is usually what makes text look wrong on a Wayland desktop.

What genuinely needs configuration is which real font each generic family resolves to, plus emoji and icon fallback. Create `/etc/fonts/local.conf` using the same approach as the reference system:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

  <!-- Pin generic families to real installed fonts. -->
  <match target="pattern">
    <test name="family" qual="any"><string>sans-serif</string></test>
    <edit name="family" mode="assign" binding="strong"><string>Liberation Sans</string></edit>
  </match>

  <match target="pattern">
    <test name="family" qual="any"><string>serif</string></test>
    <edit name="family" mode="assign" binding="strong"><string>Liberation Serif</string></edit>
  </match>

  <match target="pattern">
    <test name="family" qual="any"><string>monospace</string></test>
    <edit name="family" mode="assign" binding="strong"><string>JetBrainsMono Nerd Font</string></edit>
  </match>

  <!-- Web and toolkit UI families used by browsers and Electron apps. -->
  <alias>
    <family>system-ui</family>
    <prefer><family>Liberation Sans</family></prefer>
  </alias>

  <alias>
    <family>-apple-system</family>
    <prefer><family>Liberation Sans</family></prefer>
  </alias>

  <alias>
    <family>BlinkMacSystemFont</family>
    <prefer><family>Liberation Sans</family></prefer>
  </alias>

  <alias>
    <family>ui-monospace</family>
    <default><family>monospace</family></default>
  </alias>

  <!-- Fallback: emoji everywhere, Nerd Font icon glyphs in UI text. -->
  <alias>
    <family>sans-serif</family>
    <accept>
      <family>JetBrainsMono Nerd Font</family>
      <family>Noto Color Emoji</family>
    </accept>
  </alias>

  <alias>
    <family>serif</family>
    <accept><family>Noto Color Emoji</family></accept>
  </alias>

  <alias>
    <family>monospace</family>
    <accept><family>Noto Color Emoji</family></accept>
  </alias>

</fontconfig>
```

Why each part matters:

```text
Generic family pinning
    Stops applications from resolving sans-serif/monospace to an
    arbitrary installed font, which is the usual cause of
    inconsistent-looking UI text.

system-ui / -apple-system / BlinkMacSystemFont
    Web pages, Chromium, and Electron request these names directly.
    Without aliases they fall back unpredictably.

emoji + Nerd Font accept rules
    Gives every generic family a defined fallback chain, so emoji and
    icon glyphs render instead of showing tofu boxes.
```

If you also need Arabic, Hebrew, or other scripts where a default pick is wrong, add targeted `lang` rules rather than reordering the global font list.

Rebuild the font cache and confirm the result:

```bash
fc-cache -fv
fc-match sans-serif
fc-match serif
fc-match monospace
fc-match system-ui
fc-match emoji
```

Expected on this configuration:

```text
sans-serif   Liberation Sans
serif        Liberation Serif
monospace    JetBrainsMono Nerd Font
system-ui    Liberation Sans
emoji        Noto Color Emoji
```

To change only the monospace font later, do it per user instead of editing the system file. Create `~/.config/fontconfig/fonts.conf`:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family" qual="any"><string>monospace</string></test>
    <edit name="family" mode="prepend_first" binding="strong"><string>CaskaydiaMono Nerd Font</string></edit>
  </match>
</fontconfig>
```

User configuration loads after the system file, and `prepend_first` puts the chosen family ahead of the pinned default.

The family name must match an installed font exactly, otherwise fontconfig silently falls back to the pinned default. Confirm it first:

```bash
fc-list : family | tr ',' '\n' | sort -u | grep -i mono
fc-match monospace
```

Terminals that keep their own font setting, such as `foot`, must also be updated in their own configuration:

```ini
font=JetBrainsMono Nerd Font:size=11
```

### 12.4 Enable SDDM

```bash
systemctl enable sddm.service
```

The Arch `hyprland` package provides both:

```text
/usr/share/wayland-sessions/hyprland.desktop
/usr/share/wayland-sessions/hyprland-uwsm.desktop
```

Select **Hyprland (uwsm-managed)** in SDDM. Do not create a duplicate user-local session entry unless the packaged entry is genuinely unsuitable.

### 12.5 Audio activation

Do not run `systemctl --user` inside the root chroot. PipeWire and WirePlumber use packaged user units and sockets that become available in the real user session.

### 12.6 GNOME Keyring and PAM

Install the packages now, but inspect SDDM’s packaged PAM files after boot before changing them:

```text
/etc/pam.d/sddm
/etc/pam.d/sddm-autologin
```

Do not duplicate existing `pam_gnome_keyring.so` lines. Automatic login normally cannot unlock a keyring protected by the login password.

---

## 13. Optional system features before reboot

### 13.1 zram

Install:

```bash
pacman -S zram-generator
```

Create `/etc/systemd/zram-generator.conf`:

```ini
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
```

The configured size is virtual compressed-swap capacity, not preallocated physical RAM.

### 13.2 Bluetooth

```bash
pacman -S bluez bluez-utils
systemctl enable bluetooth.service
```

Install `blueman` only if you want its GUI.

### 13.3 Printing

```bash
pacman -S cups cups-filters system-config-printer
systemctl enable cups.service
```

### 13.4 Firewall

For a workstation firewall:

```bash
pacman -S ufw
ufw default deny incoming
ufw default allow outgoing
```

Do not run `ufw enable` from the chroot: it shares the live ISO's network namespace and could interrupt a remote installation. Activate it after a successful local boot in section 15.

---

## 14. Reboot into the installed system

Review the essentials first:

```bash
findmnt -R /
cat /etc/fstab
ls -lh /boot/EFI/Linux/
bootctl list
systemctl is-enabled NetworkManager systemd-resolved systemd-timesyncd sddm
```

Exit the chroot:

```bash
exit
```

Back in the live ISO, create the firmware entry using the real disk and ESP partition number:

```bash
efibootmgr --create \
  --disk /dev/nvme0n1 \
  --part 1 \
  --label "Linux Boot Manager" \
  --loader '\EFI\systemd\systemd-bootx64.efi'

efibootmgr -v
```

Confirm the new entry exists. Then unmount and reboot:

```bash
umount -R /mnt
reboot
```

Remove the installation USB when the firmware begins rebooting.

If the machine does not boot, return to the ISO, mount the Btrfs subvolumes and ESP again, then use `arch-chroot /mnt` to repair the installation.

---

## 15. First-login user configuration

Everything from this point runs as the regular user after logging into **Hyprland (uwsm-managed)** through SDDM.

### 15.1 Confirm the UWSM session

```bash
printf 'type=%s desktop=%s\n' "$XDG_SESSION_TYPE" "$XDG_CURRENT_DESKTOP"
systemctl --user status graphical-session.target --no-pager
systemctl --user status 'wayland-wm@hyprland.desktop.service' --no-pager
```

Expected:

```text
type=wayland desktop=Hyprland
```

The exact UWSM unit names can vary by version. Inspect them with:

```bash
systemctl --user list-units --all | grep -Ei 'wayland|hyprland|graphical'
```

### 15.2 Configure the UWSM environment

Use the session environment for variables that must exist before Hyprland starts:

```bash
mkdir -p ~/.config/uwsm/env.d
```

Create `~/.config/uwsm/env.d/10-wayland`:

```bash
export GDK_BACKEND="wayland,x11,*"
export QT_QPA_PLATFORM="wayland;xcb"
export MOZ_ENABLE_WAYLAND="1"
export ELECTRON_OZONE_PLATFORM_HINT="wayland"
export XDG_CURRENT_DESKTOP="Hyprland"
export XDG_SESSION_DESKTOP="Hyprland"
```

Modern Firefox, Chromium, Electron, GTK, and Qt increasingly select Wayland without overrides. Keep this file small and remove compatibility variables when they are no longer needed.

Log out and back in after changing pre-session environment files.

### 15.3 Hybrid GPU selection

Inspect stable DRM paths:

```bash
ls -l /dev/dri/by-path/

for card in /sys/class/drm/card[0-9]; do
  printf '%s vendor=' "$(basename "$card")"
  cat "$card/device/vendor"
  printf ' driver='
  basename "$(readlink -f "$card/device/driver")"
done
```

Do not assume `card0` is Intel or `card1` is NVIDIA. Card numbers can change.

Confirm which GPU physically owns the connected monitor:

```bash
for conn in /sys/class/drm/card[0-9]-*; do
  [ -r "$conn/status" ] || continue
  printf '%-24s %s\n' "$(basename "$conn")" "$(cat "$conn/status")"
done
```

A connector named `card1-HDMI-A-3` reporting `connected` means the monitor is wired to `card1`. Cross-reference that with the vendor output above: `0x10de` is NVIDIA, `0x8086` is Intel, `0x1002` is AMD.

Normally, let Hyprland select the GPU that owns the connected display. The reference Intel + NVIDIA desktop had its monitor connected directly to NVIDIA, and Hyprland correctly ran on NVIDIA with `AQ_DRM_DEVICES` left unset.

Only set `AQ_DRM_DEVICES` when automatic selection is wrong or a deliberate multi-GPU order is required. Put it in the UWSM environment so it exists before Hyprland starts. Use the real stable paths from `/dev/dri/by-path/`, for example:

```bash
export AQ_DRM_DEVICES="/dev/dri/by-path/pci-0000:01:00.0-card:/dev/dri/by-path/pci-0000:00:02.0-card"
```

Every GPU that owns a connected monitor must remain available. Do not create custom `/dev/dri/intel` and `/dev/dri/nvidia` udev links when the existing `by-path` links are sufficient.

### 15.4 NVIDIA application environment

Which variables to set depends on whether NVIDIA is the primary renderer, and on the GPU generation.

#### NVIDIA-primary desktop

Add these to the UWSM environment, for example `~/.config/uwsm/env.d/20-nvidia`:

```bash
export __GLX_VENDOR_LIBRARY_NAME="nvidia"
export NVD_BACKEND="direct"
export LIBVA_DRIVER_NAME="nvidia"
```

`NVD_BACKEND` depends on GPU generation, and the reference system chose it by detecting GSP firmware:

```text
Turing or newer (RTX 20-series and later, PCI device id >= 0x1e00)
    NVD_BACKEND=direct

Maxwell, Pascal, Volta
    NVD_BACKEND=egl
    and do not set LIBVA_DRIVER_NAME
```

Check the generation of the installed NVIDIA GPU:

```bash
for dev in /sys/bus/pci/devices/*; do
  [ "$(cat "$dev/vendor" 2>/dev/null)" = 0x10de ] || continue
  case "$(cat "$dev/class" 2>/dev/null)" in
    0x03*) printf '%s device=%s\n' "$(basename "$dev")" "$(cat "$dev/device")" ;;
  esac
done
```

A device id of `0x1e00` or higher is Turing or newer, so `direct` is correct.

`LIBVA_DRIVER_NAME=nvidia` also requires the `libva-nvidia-driver` package. Set it only when NVIDIA VA-API decoding is genuinely wanted.

#### Intel-primary hybrid laptop

Do **not** set those variables globally. Keep Intel/Mesa as the desktop and video-decode path, then offload individual programs.

If `nvidia-prime` is installed:

```bash
prime-run PROGRAM
```

If it is not installed, `prime-run` is only a wrapper around environment variables, so the same result is available directly:

```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia PROGRAM
```

A convenient shell function avoids repeating it:

```bash
nvrun() {
  __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia \
  __VK_LAYER_NV_optimus=NVIDIA_only "$@"
}
```

For Vulkan, `__VK_LAYER_NV_optimus=NVIDIA_only` selects the NVIDIA device. For Mesa-driven offload between two Mesa GPUs, use `DRI_PRIME=1` instead.

Do not mix approaches: forcing NVIDIA globally while Intel presents the display causes cross-GPU buffer copies, browser GPU crashes, and unnecessary dGPU power draw.

### 15.5 Create a minimal standard Hyprland configuration

Hyprland 0.55 and newer use Lua as the primary configuration format. The older `hyprland.conf` format is deprecated and may be removed.

Hyprland normally creates `~/.config/hypr/hyprland.lua` on first launch. Replace it with a minimal configuration and extend it gradually:

```lua
-- Monitor scale and the GTK integer scale are kept in sync; see 15.6.
local monitor_scale = 1
local gdk_scale = 1

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = monitor_scale,
})

-- Cursor size must be set for both XWayland and hyprcursor clients.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GDK_SCALE", tostring(gdk_scale))

local terminal = "uwsm app -- foot"
local menu = "uwsm app -- fuzzel"

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
    hl.exec_cmd("udiskie --automount --no-notify")
end)

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
    },
    decoration = {
        rounding = 8,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + D", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("PRINT", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
hl.bind("SUPER + mouse:273", hl.dsp.window.resize())
```

`hyprpaper` and `hypridle` are installed but intentionally not autostarted above. Add them only after creating valid `~/.config/hypr/hyprpaper.conf` and `~/.config/hypr/hypridle.conf` files.

Validate after saving:

```bash
hyprctl reload
hyprctl configerrors
```

If your installed Hyprland version changed an option, trust `hyprctl configerrors` and the documentation shipped for that version.

### 15.6 Monitors, fractional scaling, and sharp text

List detected outputs and modes:

```bash
hyprctl monitors all
```

Then replace the generic declaration with the real output, for example:

```lua
local monitor_scale = 1.25
local gdk_scale = 1

hl.monitor({
    output = "HDMI-A-3",
    mode = "3440x1440@100",
    position = "0x0",
    scale = monitor_scale,
})

hl.env("GDK_SCALE", tostring(gdk_scale))
```

Use the connector name and refresh rate reported by `hyprctl`; do not copy values from another machine.

#### The scaling rule that actually matters

Three settings must agree, or text becomes blurry or mis-sized:

```text
monitor scale          fractional, e.g. 1.25   (compositor-side)
xwayland force_zero_scaling = true             (no compositor resampling)
GDK_SCALE              nearest integer to the monitor scale
```

With `force_zero_scaling = true`, Hyprland stops upscaling XWayland surfaces, which removes the blurry resampled look. The cost is that X11 applications must size themselves, and GTK only accepts **integer** `GDK_SCALE` values. The reference system therefore stores the nearest whole number next to the fractional monitor scale:

```text
monitor scale 1.00  →  GDK_SCALE 1
monitor scale 1.25  →  GDK_SCALE 1
monitor scale 1.50  →  GDK_SCALE 2
monitor scale 1.75  →  GDK_SCALE 2
monitor scale 2.00  →  GDK_SCALE 2
```

So on a 3440x1440 display at scale `1.25`, the correct value is `GDK_SCALE=1`. Setting `2` there is the classic mistake that makes XWayland applications enormous.

Keep both values in one place, as above, so they cannot drift apart.

#### Choosing a valid fractional scale

Hyprland rejects scales that do not divide the pixel dimensions cleanly. If `hyprctl configerrors` complains about the scale, pick a nearby value such as `1.2`, `1.25`, or `1.5`, then confirm the applied result:

```bash
hyprctl monitors -j | grep -E '"name"|"scale"'
```

#### Do not stack scaling hacks

Leave these unset unless a single specific application requires them:

```text
GDK_DPI_SCALE
QT_SCALE_FACTOR
QT_AUTO_SCREEN_SCALE_FACTOR
QT_FONT_DPI
```

Qt already follows the Wayland scale through `qt6-wayland`. Combining compositor scaling, `GDK_SCALE`, and `QT_SCALE_FACTOR` multiplies the factors and produces oversized or fuzzy UI.

Prefer native Wayland for anything rendering text. Check what a window is actually using:

```bash
hyprctl clients | grep -E 'class|xwayland'
```

`xwayland: 0` means native Wayland, which gives correct fractional scaling and the sharpest text. `xwayland: 1` means the application goes through XWayland and is subject to the integer-scaling rules above.

Use the connector name and refresh rate reported by `hyprctl`; do not copy a connector name from another machine.

### 15.7 Verify portals

```bash
systemctl --user status xdg-desktop-portal.service --no-pager
systemctl --user status xdg-desktop-portal-hyprland.service --no-pager
systemctl --user status xdg-desktop-portal-gtk.service --no-pager
```

Hyprland’s backend handles compositor-specific screenshot and screencast interfaces. The GTK backend supplies interfaces such as a GTK file chooser where appropriate.

After changing portal packages or configuration, log out and back in rather than repeatedly spawning portal processes by hand.

### 15.8 Verify audio

```bash
systemctl --user status pipewire.service wireplumber.service --no-pager
wpctl status
```

Do not install PulseAudio alongside `pipewire-pulse`.

### 15.9 Initialize user directories

```bash
xdg-user-dirs-update
```

Review `~/.config/user-dirs.dirs` if you do not want a desktop directory.

### 15.10 Activate the firewall

After confirming local login and networking work, configure any required inbound exceptions **before** enabling UFW. For an SSH server:

```bash
sudo ufw limit ssh
```

Then activate and verify the firewall:

```bash
sudo ufw enable
sudo systemctl enable ufw.service
sudo ufw status verbose
```

Skip the SSH rule if no SSH server is installed.

### 15.11 Optional Snapper setup

Snapshots are useful but are not backups. Because `@home`, `@pkg`, `@log`, and `@swap` are separate subvolumes, root snapshots do not include their contents.

Let Snapper create and manage its own `/.snapshots` layout:

```bash
sudo pacman -S snapper
sudo snapper -c root create-config /
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
```

Do not pre-create a mounted `@snapshots` subvolume and then run `create-config` without following a deliberate Snapper subvolume procedure.

---

## 16. Optional hibernation with Btrfs

zram cannot store a hibernation image across power-off. Hibernation needs persistent disk swap large enough for the expected image.

Test suspend first. Add hibernation only after the normal boot, GPU, and resume paths are stable.

### 16.1 Create a Btrfs swapfile

The installation created and mounted the dedicated `@swap` subvolume at `/swap`, outside the root snapshot boundary. Use Btrfs’s dedicated helper:

```bash
sudo btrfs filesystem mkswapfile --size 16G --uuid clear /swap/swapfile
sudo swapon /swap/swapfile
```

Choose a size appropriate for RAM usage and hibernation policy.

Add it to `/etc/fstab` with lower priority than zram:

```text
/swap/swapfile none swap defaults,pri=0 0 0
```

Verify:

```bash
swapon --show
```

### 16.2 Add resume parameters

Get the Btrfs filesystem UUID and physical swapfile offset:

```bash
findmnt -no UUID /
sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
```

Append these values to `/etc/kernel/cmdline`:

```text
resume=UUID=YOUR-BTRFS-UUID resume_offset=YOUR-OFFSET
```

Then regenerate the UKIs:

```bash
sudo mkinitcpio -P
```

Verify the command line embedded in the UKI before testing. NVIDIA hibernation behavior depends on the driver branch, video-memory use, and available storage; do not enable legacy NVIDIA suspend services merely because an old guide lists them.

---

## 17. Optional containers and firewall considerations

Install Docker only if needed:

```bash
sudo pacman -S docker docker-buildx docker-compose
sudo systemctl enable --now docker.socket
```

Starting `docker.socket` provides on-demand activation. Enable `docker.service` directly instead if you deliberately want the daemon running continuously.

Adding a user to the `docker` group grants effectively root-equivalent access:

```bash
sudo usermod -aG docker "$USER"
```

Log out and back in for group changes to apply.

Docker manages firewall and NAT rules. Do not assume UFW protects every published container port. Prefer binding development services to localhost:

```yaml
ports:
  - "127.0.0.1:8080:8080"
```

instead of exposing them on every host interface:

```yaml
ports:
  - "8080:8080"
```

Audit any third-party Docker/UFW integration package before installation.

---

## 18. Verification checklist

Run this after the first successful graphical login.

### 18.1 Boot and filesystems

```bash
test -d /sys/firmware/efi/efivars && echo UEFI
bootctl status
bootctl list
findmnt /
findmnt /boot
findmnt /home
findmnt /var/cache/pacman/pkg
findmnt /var/log
ls -lh /boot/EFI/Linux/
cat /proc/cmdline
```

Expected root properties include Btrfs and `subvol=@`.

### 18.2 System health

```bash
systemctl --failed
systemctl --user --failed
journalctl -b -p warning..alert --no-pager
```

Some warnings are harmless; investigate repeated hardware, filesystem, GPU, or service failures.

### 18.3 Network and DNS

```bash
nmcli general status
nmcli device status
resolvectl status
ls -l /etc/resolv.conf
ping -c 3 archlinux.org
```

`/etc/resolv.conf` should point to the `systemd-resolved` stub.

### 18.4 Graphics

```bash
lspci -nnk | grep -A4 -E 'VGA compatible controller|3D controller|Display controller'
ls -l /dev/dri/by-path/
glxinfo -B
vulkaninfo --summary
vainfo
```

For NVIDIA:

```bash
nvidia-smi
lsmod | grep '^nvidia'
sudo cat /sys/module/nvidia_drm/parameters/modeset
```

`glxinfo` needs `mesa-utils`, `vainfo` needs `libva-utils`, and `vulkaninfo` needs `vulkan-tools`. Install them before expecting these checks to work.

On a hybrid system, confirm that both GPUs are visible and that the expected one is primary:

```bash
vulkaninfo --summary | grep -E 'deviceName|driverName'
glxinfo -B | grep -E 'OpenGL renderer|OpenGL vendor'
```

For offload, use whichever form matches the installed packages:

```bash
# with nvidia-prime
prime-run glxinfo -B | grep 'OpenGL renderer'

# without nvidia-prime
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia \
  glxinfo -B | grep 'OpenGL renderer'
```

The reported renderer should change to the NVIDIA GPU. If it does not, the offload variables are not reaching the process.

Check which processes currently hold the NVIDIA GPU:

```bash
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
nvidia-smi
```

On an NVIDIA-primary desktop, seeing Hyprland, Xwayland, and the browser here is expected. On an Intel-primary laptop, an idle dGPU should show no clients and a low power state.

### 18.5 Wayland, Hyprland, and UWSM

```bash
printf '%s\n' "$XDG_SESSION_TYPE" "$XDG_CURRENT_DESKTOP"
hyprctl version
hyprctl monitors
hyprctl devices
hyprctl configerrors
systemctl --user list-units --all | grep -Ei 'wayland|hyprland|graphical'
```

### 18.6 Portals, audio, and polkit

```bash
systemctl --user status \
  xdg-desktop-portal.service \
  xdg-desktop-portal-hyprland.service \
  pipewire.service \
  wireplumber.service \
  hyprpolkitagent.service \
  --no-pager

wpctl status
```

### 18.7 Fonts, scaling, and rendering

Confirm generic family resolution:

```bash
fc-match sans-serif
fc-match serif
fc-match monospace
fc-match system-ui
fc-match emoji
```

Confirm the expected fontconfig files are active, and that nothing added aggressive hinting or subpixel overrides:

```bash
ls -l /etc/fonts/conf.d/ | grep -E 'hinting|antialias|lcdfilter|local'
ls -l /etc/fonts/local.conf ~/.config/fontconfig/fonts.conf 2>/dev/null
```

Expected: stock `10-yes-antialias.conf`, `10-hinting-slight.conf`, and `11-lcdfilter-default.conf` symlinks, plus your own `local.conf`.

Confirm scaling agreement:

```bash
hyprctl monitors -j | grep -E '"name"|"scale"'
printf 'GDK_SCALE=%s\n' "${GDK_SCALE:-unset}"
printf 'QT_SCALE_FACTOR=%s\n' "${QT_SCALE_FACTOR:-unset}"
hyprctl getoption xwayland:force_zero_scaling
```

`GDK_SCALE` must be the nearest integer to the monitor scale, and `QT_SCALE_FACTOR` should normally be unset.

Identify whether a blurry window is native Wayland or XWayland before changing anything:

```bash
hyprctl clients | grep -E 'class|title|xwayland'
```

Verify emoji and icon glyphs render by printing a mixed sample in the terminal:

```bash
printf 'ascii AVWij 0O1l \u2014 emoji \U0001F600 \u2014 nerd \uf015 \ue0b0\n'
```

Missing boxes indicate a fallback gap in `local.conf`, not a broken renderer.

### 18.8 Memory and firewall

```bash
free -h
swapon --show
sudo ufw status verbose
```

---

## 19. Troubleshooting order

### 19.1 Boot failure

1. Boot the Arch ISO in UEFI mode.
2. Mount `@`, the other subvolumes, and the ESP exactly as in section 5.
3. Run `arch-chroot /mnt`.
4. Check `/etc/fstab`, `/etc/kernel/cmdline`, and `/etc/mkinitcpio.d/linux.preset`.
5. Run `mkinitcpio -P` and read every error.
6. Run `bootctl status` and `bootctl list`.

### 19.2 Black screen or missing monitor

From a TTY:

```bash
lspci -nnk | grep -A4 -E 'VGA|3D|Display'
ls -l /dev/dri/by-path/
lsmod | grep -E '^(i915|xe|amdgpu|nvidia)'
journalctl -b --grep='drm|nvidia|i915|xe|amdgpu|hyprland' --no-pager
```

Check which GPU physically owns the connector. Avoid random kernel parameters until logs identify a specific failure.

### 19.3 Hyprland session failure

```bash
systemctl --user status 'wayland-wm@hyprland.desktop.service' --no-pager
journalctl --user -b --grep='uwsm|hyprland' --no-pager
hyprctl configerrors
```

If the graphical session cannot start, temporarily select the non-UWSM Hyprland session or log in on a TTY to repair the configuration.

### 19.4 Screen sharing or file-picker failure

```bash
systemctl --user status xdg-desktop-portal.service --no-pager
journalctl --user -b --grep='xdg-desktop-portal' --no-pager
```

Confirm exactly one appropriate compositor portal backend is installed and that the session reports `XDG_CURRENT_DESKTOP=Hyprland`.

### 19.5 Audio failure

```bash
systemctl --user status pipewire.service pipewire-pulse.service wireplumber.service --no-pager
journalctl --user -b -u pipewire -u pipewire-pulse -u wireplumber --no-pager
wpctl status
```

### 19.6 DNS failure

```bash
nmcli device status
resolvectl status
ls -l /etc/resolv.conf
journalctl -b -u NetworkManager -u systemd-resolved --no-pager
```

Do not replace `/etc/resolv.conf` with a static file unless intentionally abandoning `systemd-resolved`.

### 19.7 Blurry or wrongly sized text

Work through this in order and stop at the first cause; do not install font packages to fix a scaling problem.

1. Determine the window type:

   ```bash
   hyprctl clients | grep -E 'class|xwayland'
   ```

2. If it is XWayland, check the scaling triple:

   ```bash
   hyprctl monitors -j | grep -E '"name"|"scale"'
   hyprctl getoption xwayland:force_zero_scaling
   printf 'GDK_SCALE=%s\n' "${GDK_SCALE:-unset}"
   ```

   `GDK_SCALE` must be the nearest integer to the monitor scale.

3. If it is native Wayland, the application is scaling itself. Check for stray overrides:

   ```bash
   env | grep -E 'GDK_|QT_|_SCALE|DPI'
   ```

4. Only then look at font selection:

   ```bash
   fc-match monospace
   fc-match sans-serif
   ```

5. Prefer running the application natively on Wayland instead of compensating with scale factors.

### 19.8 Missing glyphs, boxes, or wrong script

```bash
fc-match emoji
fc-list | grep -ciE 'nerd|noto color emoji'
fc-match --sort sans-serif | head -5
```

If glyphs are missing, add the appropriate `accept` fallback in `/etc/fonts/local.conf` and rebuild the cache with `fc-cache -fv`. Chromium and Electron resolve missing glyphs per character, so a generic last-resort fallback family is what fixes them, not a new font package.

After editing fontconfig, restart the affected applications; long-running ones cache font lookups.

### 19.9 Browser video or GPU problems

```bash
nvidia-smi
vainfo 2>&1 | head -20
env | grep -E 'LIBVA_DRIVER_NAME|NVD_BACKEND|__GLX_VENDOR_LIBRARY_NAME'
```

In Chromium-based browsers check `chrome://gpu`; in Firefox check `about:support`.

Rules:

- Do not disable hardware acceleration as a first response.
- On an Intel-primary hybrid system, do not set `LIBVA_DRIVER_NAME=nvidia`.
- On an NVIDIA-primary system, `LIBVA_DRIVER_NAME=nvidia` requires `libva-nvidia-driver`, and `NVD_BACKEND` must match the GPU generation from section 15.4.
- Verify the browser runs on Wayland rather than XWayland before blaming the GPU driver.

---

## 20. Maintenance rules

Update the complete system together:

```bash
sudo pacman -Syu
```

Do not perform partial upgrades such as installing packages after refreshing databases without upgrading the installed system.

After kernel, initramfs, or NVIDIA changes, confirm UKI generation succeeded:

```bash
ls -lh /boot/EFI/Linux/
bootctl list
```

Review pacman `.pacnew` files:

```bash
sudo pacdiff
```

Install `pacman-contrib` if `pacdiff` is unavailable.

For AUR packages:

- build as an unprivileged user;
- read the `PKGBUILD` and related files;
- prefer official repository packages when they meet the requirement;
- rebuild AUR packages when library or toolchain updates require it.

For kernel-regression recovery, install `linux-lts` with its matching headers and a separately named UKI, or maintain a deliberate versioned-UKI retention process. The normal `fallback` UKI uses the same current kernel and is not protection against a bad kernel update.

Keep a bootable Arch USB. Snapshots are useful for logical rollback, but only an external backup protects against disk failure, theft, or destructive mistakes.
