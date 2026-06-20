### 0. Before you start

- First, download the Arch Linux installation ISO from the [Arch Linux website](https://www.archlinux.org/download/).
- Among the variety of files, choose the ISO `archlinux-xxxx.xx.xx-x86_64.iso` and signature `archlinux-xxxx.xx.xx-x86_64.iso.sig` files

- When the ISO is downloaded, you need to check its signature to make sure it has not been compromised: <br>
  `gpg --keyserver-options auto-key-retrieve --verify /path/to/archlinux.iso.sig` <br>
  If you see `“Good signature from …“`, this means everything is alright.

- Next, you need to write it to your USB flash drive. Open the Linux terminal and use the following command: <br>
  `dd bs=4M if=path/to/archlinux-version-x86_64.iso of=/dev/sdx conv=fsync oflag=direct status=progress` - **_Restore the USB drive :_** After you have used the bootable USB flash drive, you need to restore it back to its normal not-bootable state
  `sudo wipefs --all /dev/sdX` <br>
  After that create a new partition on it: <br>
  `fdisk /dev/sdX`

- #### Dual boot `Windows` + `Arch`
- If you want to install Windows11 and Arch in dual boot, first install windows.
- **After installing windows you need to go to the boot setup in your system and disable `secure boot` and `RAID` in nvme configuration part and then run arch installer**

<br>

### 1. Network Connectivity

```bash
ping google.com
```

If you get the error with the message of "Temporary failure in name resolution" just run

```bash
dhcpcd
```

Some helpful command in network testing :

```bash
ifconfig
wifi-menu -o wlp9s0
```

<br>

### 2. Set `timedatectl`

[more information](https://www.tecmint.com/set-time-timezone-and-synchronize-time-using-timedatectl-command/)

```bash
timedatectl set-ntp true
```

```bash
timedatectl set-timezone Asia/Tehran
```

<br>

### 3. Partition Hard drive

List the available partitions and disks: :

```bash
lsblk
```

To check the partition table, run:

```bash
fdisk -l
```

To partition disk:

```bash
cfdisk /dev/nvme0n[x]
```

To standard installation you need 4 partition :

- `boot` => `Size: [512M]` ==> `Type: [EFI SYSTEM]`
- `Root` => `Size: [30G]` ==> `Type: [linux file system]`
- `home` => `Size: [...]` ==> `Type: [linux file system]`
- `swap` => `Size: [moe than half of ram size]` ==> `Type: [swap]`
  > **You can skip creating swap partition and create swap file later**

<br>

### 4. Make file system

- In dual boot _windows_ and _arch_ mode, windows create 4 partition. The first partition which is EFI SYSTEM is important in installing arch linux and don't format or change it at all.

```bash
mkfs.fat -F32 /dev/nvme0n1p[boot]

mkfs.ext4 /dev/nvme0n1p[root]
# mkfs.ext4 /dev/nvme0n1p[home]
```

```bash
# If there is a swap partition
mkswap /dev/nvme0n1p[swap]
swapon /dev/nvme0n1p[swap]
```

<br>

### 5. Mounting

We have created necessary partitions and formatted them. Now, we need to mount them in order to install Arch Linux base system.

```bash
mount /dev/nvme0n1p[root] /mnt

# If there is seperated home partition
mkdir /mnt/home
mount /dev/nvme0n1p[home] /mnt/home
```

**_In Dual windows+arch mode :_**

```bash
# Mount arch boot partition
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p[boot] /mnt/boot/efi

# FOR DUAL BOOT : Mount first partition(EFI~100Mb) created by windows
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
```

Check mounting points whether they were created successfully:

```bash
lsblk
```

<br>

### Set the fastest mirror list available for you :

```bash
sudo pacman -S reflector
```

```bash
# Make Backup of mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
```

```bash
reflector -c 'United States, France' -a 12 -f 5 --protocol https --sort rate --save etc/pacman.d/mirrorlist
```

- The `-c` stands for country. If your country has a two word name, you have to put them through single quotes, as the United States is in our example above.
- The `-a` stands for the age of the servers. In our example, 12 denotes servers that have been updated in the last 12 hours.
- `--protocol https` retrieve https enabled mirrors
- The `--sort` portion is to sort the servers by speed.
- The `--save` will let you save this information under etc/pacman.d/mirrorlist.
- `-f` pick n fastest mirrors

<br>

### 6. Install Arch

```bash
pacstrap -i /mnt base base-devel linux linux-firmware vim
```

<br>

### 7. Generating fstab file

```bash
genfstab -U -p /mnt >> /mnt/etc/fstab
```

<br>

### 8. Arch Linux basic Configuration

- ### chroot (change root) to your system that is mounted to `/mnt`:

```bash
arch-chroot /mnt
```

- ### Configure the system language:
  Uncomment `en_US.UTF-8 UTF-8`, as well as other needed localisations.

```bash
 vim /etc/locale.gen
```

Then, generate the new locales :

```bash
locale-gen
```

Create `/etc/locale.conf` file:

```bash
vim /etc/locale.conf
```

And put this line inside it:

```bash
LANG=en_US.UTF-8
```

Save and close the file.

- ### System timezone
  List out the available timezones using command:

```bash
ls /usr/share/zoneinfo/
```

and there is a path should link to one of the timezone :

```bash
ls /etc/localtime
```

or use

```bash
timedatectl set-timezone Iran
```

For create link run the command:

```bash
ln -sf /usr/share/zoneinfo/[iran] /etc/localtime
```

Set local time :

```bash
hwclock --systohc --utc
```

And check the time:

```bash
date
```

If the time is incorrect, go back and make sure you have set the timezone correctly.

- ### Set Password
  Set `root` user password with command:

```bash
passwd
```

- ### Network configuration
  A hostname is the computer’s name. for example `archPC`
  Edit `/etc/hostname` file and add `archPC` to :

```bash
vim /etc/hostname   # Enter a name like archPC
```

Save and close the file.

<br>

Then, edit `/etc/hosts` file and set the hostname as well.Be mindful that you need to set the same hostname in the both files.
in `etc/hosts`

```
127.0.0.1	localhost
#::1		localhost   				# ipv6 could show your original IP address when connecting to VPNs
127.0.1.1	archPC.localdomain	localhost       #  archpc :--> hostname
```

To disable `IPv6` create `/etc/sysctl.d/ipv6.conf ` and Add these line to :

```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

```bash
sudo sysctl -p /etc/sysctl.d/ipv6.conf
sudo sysctl --system
```

if you have IPv6 hots in `/etc/hosts` comment that lines : `sed -i 's/^[[:space:]]*::/#::/' /etc/hosts`

for check it's disabled :

```bash
cat /proc/sys/net/ipv6/conf/all/disable_ipv6
```

<br>

Then make Network connections persistent using commands:

```bash
systemctl enable dhcpcd
```

**OR** You can use network manager:

```bash
sudo pacman -S networkmanager network-manager-applet networkmanager-openvpn
systemctl enable NetworkManager
```

<br>

### 9. Grub installation

```
/dev/nvme0n1p[boot] 	                                --> mount to /boot
/dev/nvme0n1p1 (EFI-First Partition created by windows) --> mount to /boot/efi
```

Check if everything is mounted correctly : `lsblk`

## Install grub

To install the boot loader, run command below :

```bash
pacman -S grub efibootmgr dosfstools mtools intel-ucode
```

if you don't want to add other os to the grub, just mount boot partition and install grub as shown below (without installing nad enable `os-prober`).

### For Adding Other OS to the grub automatically (better):

- #### Add automatically with `os-prober` :
  `pacman -S os-prober` is utility if you have more than one OS on your machine. It will **automate** the process of adding other operating systems to grub menu for easy dual booting.

**If your purpose is dual boot with `os-prober` , go to the `/etc/default/grub` and at the last line uncomment the :**
`GRUB_DISABLE_OS_PROBER="false"` and mount boot partition to efi directory :

- First run :

```
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
```

> you can add `--recheck --removable` to the command

- Then run command below to install grub.

```
grub-mkconfig -o /boot/grub/grub.cfg
```

<br>

You need change grub priority in BIOS setup to make it work properly.

<br>

- #### Add manually with customizing `/etc/grub.d/40_custom`:
  For adding windows [**_manually_**](https://wiki.archlinux.org/title/GRUB#Windows_installed_in_UEFI/GPT_mode) to the grub, go to the `/etc/grub.d/40_custom` and add this codes to the end of the file. at the end your file is like this:

```
#!/bin/sh
exec tail -n +3 $0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.

if [ "${grub_platform}" == "efi" ]; then
  menuentry "Windows 11" {
    insmod part_gpt
    insmod fat
    insmod search_fs_uuid
    insmod chain
    # use:
    # after --set=root, add the EFI partition's UUID
    # this can be found with either:
    #
    # a. blkid
    # - or -
    # b. grub-probe --target=fs_uuid /boot/efi/EFI/VeraCrypt/DcsBoot.efi
    #
    search --fs-uuid --set=root $FS_UUID
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
  }
fi
```

- Important Change in file `40_custom`:
  you need to change `$FS_UUID` to the UUID of the the first partition created by windows which is EFI and has 100 Mb storage.
  for finding UUID, use :

```
blkid
```

and then find `UUID` of `/dev/nvme0n1p1` and replace with `$FS_UUID` in file `40_custom`.
the line will change to something like this :

```
search --fs-uuid --set=root 5EBD-11D6
```

After Changing file, you need to run :

`grub-install` and then `grub -o /boot/grub/grub.cfg` to install grub.

Now, For checking process you should see `windows 11` menuentry in `/boot/grub/grub.cfg` file.

##### To check what OS grub detected :

```bash
ls /boot/efi/EFI/
```

- _after installing arch linux completely you can use GUI app for customizing grub menu with `sudo pacman -S grub-customizer`_

- Install `ntfs-3g` for recognize NTFS partitions:

```bash
sudo pacman -S ntfs-3g
```

<br>

### 10. exit

```bash
exit
umount -R /mnt
reboot
```

<br>

- ## Enable NTP service to adjust time automatically

```bash
pacman -Syu ntp
```

```bash
systemctl enable ntpd.service
systemctl start ntpd.service
```

- ###### Change time format to RTC (for dual boot users with windows) :

```bash
timedatectl set-local-rtc 1 --adjust-system-clock
```

<br>

## Creating Swap File instead of Swap partition

**_Note : hibernation work better with Swap partition_**
Alternatively, you can create a Linux Swap File after the installation. The modern Linux Kernel allows Swapping to a swap file instead of a swap partition. A swap file has an advantage over a swap partition that you can change the size of your swap any time easily by changing a swap file size.

Create a Swap file of 8 Gigabyte or whatever your RAM size is:

```bash
fallocate -l 8G /swapfile
```

Change its access rules, format and enable it:

```bash
chmod 600 /swapfile
mkswap /swapfile	# format the file to swap.
swapon /swapfile	# enable the swap
```

Also, add this Swap file to the `/etc/fstab`:

```bash
/swapfile	none	swap	sw	0 0
```

And check if the Swap file is working:

```bash
free -m
```

#### Remove a Linux Swap File

In case you need to remove a Linux swap file for any reason, you need to follow these steps.

First, deactivate the swap.

```bash
sudo swapoff -v /swapfile
```

If you created the entry in the `/etc/fstab` file, remove it. To remind you, it is the line: `/swapfile swap swap defaults 0 0` entry.

Finally, delete the actual Linux Swap File.

`sudo rm /swapfile`

#### Adjust the Swappiness value

Swappiness is a property of the Linux Kernel to define how often the swap space will be used.

Normally, the default swappiness value is `60`. The smaller this value, the more of your RAM will be used.

To verify the swappiness value, run this command:

```bash
cat /proc/sys/vm/swappiness
```

If you want to modify the default value, you need to edit the file `/etc/sysctl.conf` .

```bash
sudo vim /etc/sysctl.conf
```

And add the following (10 is the most commonly recommended value):

```bash
vm.swappiness=10
```

<br>

## Post Installation

### Update your system

```bash
pacman -Syu
```

<br>

### Configure Package manager

It is always a good idea to keep an updated mirrorlist.To do so ,go to Pacman Mirrorlist Generator page and select your nearest mirror:
https://www.archlinux.org/mirrorlist/
Then, copy the mirrorlist location and Paste the lines at the top of **`/etc/pacman.d/mirrorlist`** file.
Then, update the update the package repositories list with command:

```bash
pacman -Syy
```

- #### Add some color to the package manager:
  Uncomment `color` in `etc/pacman.conf` :

```bash
...
Color
...
```

### Create a normal user account

It is pretty bad idea to use the root user for normal computing tasks. So, let create a normal user

```bash
useradd -m -g users -G wheel,storage,power,audio,video -s /bin/bash [username]
passwd [username]
```

First set EDITOR to your favorite

```bash
echo  export EDITOR=vim >> ~/.bashrc
```

```bash
source ~/.bashrc
```

Next, add the new user ‘<username>’ to the sudoers group to perform administrative tasks.
To do so, run:

```bash
visudo
```

Find and uncomment the following line:

```bash
%wheel ALL=(ALL:ALL) ALL
```

This means the new users that are belongs to Wheel group can perform administrative tasks using sudo command. Remember we have added the new user ‘<username>’ to the Wheel group while we create him.

<br>

## Install X window system

### Install X server

```bash
pacman -S xorg xorg-apps xorg-xinit xdotool xclip xsel
```

<br>

### Install A Display Manager

#### LightDM

- ###### Install LightDM and LightDM greeter
  LightDM is a cross-platform X display manager.Also a greeter is a GUI that prompts the user for credentials, lets the user select a session, and so on.

```bash
pacman -S lightdm
pacman -S lightdm-gtk-greeter
```

- ###### Set default LightDM greeter
  To set a default greeter for your Arch LightDM, edit the file : **`/etc/lightdm/lightdm.conf`.**
  the line in the file we look something like this:

```bash
...
[Seat:*]
...
greeter-session=lightdm-yourgreeter-greeter
...

```

- ###### Start and Enable LightDM
  On Arch, LightDM service is controlled by systemd.

```bash
systemctl enable lightdm.service
```

- ###### Enable LightDM autologin
  to autologin feature to work with your LightDM, edit the configuration file `/etc/lightdm/lightdm.conf` to ensure the following line are uncommented

```bash
...
[Seat:*]
autologin-user=username
autologin-session=i3
```

After setting this, now add the user to autologin system group:

```bash
groupadd -r autologin
gpasswd -a <username> autologin
```

you can set session in lightdm and `.dmrc` session :
so in `etc/lightdm/lightdm.conf`

```
autologin-session=i3
```

and then in `/etc/lightdm/lightdm.conf` :

```
[Seat:*]
greeter-session=<lightdm-gtk-greeter>
autologin-user=<username>
autologin-session=<i3>
```

and in `~/.dmrc`:

```
[Desktop]
Session=i3
```

install `lightdm-autologin-greeter-git` :

```bash
lightdm-autologin-greeter-git
```

<br>

### Install audio drivers

```bash
sudo pacman -S pulseaudio pulseaudio-alsa pulseaudio-equalizer pulseaudio-jack pulseaudio-bluetooth
sudo pacman -S alsa-utils alsa-firmware
```

```bash
sudo pacman -S pavucontrol
```

```bash
# used in i3 config
yay -S pulseaudio-ctl
```

<br>

### Install graphics card

You can check graphic card with :

```bash
lspci | grep -E "VGA|3D"
```

**if you don’t have dedicated graphics card** : `pacman -S xf86-video-intel
`

**Nvidia** driver installation:

```bash
sudo  pacman -Syyu
```

```bash
pacman -S nvidia-open nvidia-settings cuda cudnn mesa-utils
```

##### Automatic configuration

The NVIDIA package includes an automatic configuration tool to create an Xorg server configuration file (xorg.conf) and can be run by:

```bash
nvidia-xconfig
```

##### Enable proper NVIDIA DRM driver

- Edit `/etc/default/grub` with root privileges and find the `GRUB_CMDLINE_LINUX_DEFAULT` line and append `nvidia-drm.modeset=1` inside the quotes, for example:

```
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1"
```

- Save the file and regenerate the grub config:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

##### Kernel problem troubleshooting

- **If you encounter load kernel problem with nvidia graphic card :** <br>
  Dissable Intel IBT in your grub configuration to prevent an issue with NVIDIA graphics cards  
  In `etc/default/grub`:

  ```
  ...
  GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 ibt=off quiet"
  ...
  ```

_At the end, generate `grub.cfg` again with :_ `grub-mkconfig -o /boot/grub/grub.cfg`

<br>

- [NVIDIA/Troubleshooting](https://wiki.archlinux.org/title/NVIDIA/Troubleshooting)

<br>

### Install i3

```bash
pacman -S i3 dmenu kitty firefox
```

```bash
cp /etc/X11/xinit/xinitrc ~/.xinitrc
```

and delete last line and add below script to the file `vim ~/.xinitrc` :

```bash
# twm &
# xclock ...
# xterm -geometry ...
# xterm -geometry ...

exec i3
```

#### Enable Dark theme for GTK

```bash
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
```

<br>

### Install Bluetooth

```bash
sudo pacman -S bluez bluez-utils blueman

sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service
```

- **Setting up auto connection :**
  To make your headset auto connect you need to enable PulseAudio's switch-on-connect module. Do this by adding the following lines to `/etc/pulse/default.pa`:

```
# Automatically switch to newly-connected devices
load-module module-switch-on-connect
```

Make sure that your bluetooth audio device is trusted, otherwise repeated pairing will fail.

<br>

### Install printer(for brother mfc-7360)

```bash
sudo pacman -S cups
sudo systemctl enable cups.service
sudo systemctl start cups.service

sudo pacman -S system-config-printer
yay -S brother-mfc7360n
yay -S brscan4
```

<br>

### Install codec and plugins :

```bash
sudo pacman -S wavpack libdv libmad gst-libav libdvdnav fuse-exfat libvorbis faac libdvdcss lame libmpeg2 libtheora libxv libdvdread exfat-utils a52dec faad2 flac jasper gstreamer x264 x265
```

<br>

### Enable Hibernate

- Edit `/etc/default/grub` and add `resume` as well as `resume_offset`<--(for swap file) kernel parameters :

```bash
sudo blkid 	# copy UUID of swap partition. or if your swap file located on root use UUID of root partition
```

```
GRUB_CMDLINE_LINUX_DEFAULT="
	...
	resume=UUID=75972c96-f909-4419-aba4-80c1b74bd605
	resume_offset=1492992		# Just for swap file
	...
"
```

> `resume_offset` is the offset of the swapfile from the partition start. The offset is the first entry in the `physical_offset` column of the output of `filefrag -v /swapfile`

- Update grub: `grub-mkconfig -o /boot/grub/grub.cfg`

- Add the `resume` module hook to `/etc/mkinitcpio.conf`:

```
HOOKS="base udev resume autodetect ...
```

- Rebuild the initramfs `mkinitcpio -p linux`
- Check everything works: `systemctl hibernate`

<br>

### Install Touchpad drivers

```bash
pacman -S xf86-input-{keyboard,synaptics,mouse,libinput}
```

<br>

### Install Usefull packages

```bash
pacman -S openssh unrar unzip tar xarchiver htop git wget
systemctl enable sshd.service
```

<br>

### Connecting Android phone

```bash
sudo pacman -S mtpfs gvfs-mtp gvfs-gphoto2
yay -S jmtpfs
```

<br>

### Appearance packages

```bash
# Icon Theme
yay -S flat-remix

# GTK Theme
yay -S flatplat-blue-theme
```

- #### [Apple cursor](https://github.com/ful1e5/apple_cursor)

```bash
yay -S apple_cursor
```

Edit cursor in `lxappearance`.

Download from release page `macOSMonterey` and then :

```bash
tar -xvf macOSMonterey.tar.gz
mv macOSMonterey ~/.icons/
```

and edit `~/.config/gtk-3.0/settings.ini` to :

```ini
...
gtk-cursor-theme-name=macOSMonterey
...
```

<br>

---

## Encrypted DNS :

#### DNSCRYPT-proxy

```bash
# Install dnscrypt-proxy
sudo pacman -S dnscrypt-proxy
```

**Edit dnscrypt-proxy configuration file : `vim /etc/dnscrypt-proxy/dnscrypt-proxy.toml`**

```toml
# you can sets servers you want in `server_name` and choose dns resolver
server_names = [
  'dnscrypt.eu-dk',
  'dnscrypt.eu-nl',
  'dnscrypt.uk-ipv4',
  'ffmuc.net',
  'meganerd',
  'publicarray-au',
  'scaleway-ams',
  'scaleway-fr',
  'v.dnscrypt.uk-ipv4',
]

# If you want you can change the address of port
listen_addresses = ['127.0.0.1:53000', '[::1]:53000']

# I don't use ipv6
ipv6_servers = false

# Enabling dnssec
require_dnssec = true

# set the response for blocked queries:
blocked_query_response = 'refused'

dnscrypt_ephemeral_keys = true # optional

# block the ipv6 here too
block_ipv6 = true
```

- Then setup our Anonymous DNS routes - more info [here](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Anonymized-DNS) and the Anonymized DNS relays list [here](https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v2/relays.md):

```toml
routes = [
  { server_name = 'dnscrypt.eu-dk', via = [
    'anon-meganerd',
    'anon-scaleway-ams',
  ] },
  { server_name = 'dnscrypt.eu-nl', via = [
    'anon-meganerd',
    'anon-scaleway-ams',
  ] },
  { server_name = 'dnscrypt.uk-ipv4', via = [
    'anon-scaleway',
    'anon-tiarap',
  ] },
  { server_name = 'ffmuc.net', via = [
    'anon-ibksturm',
    'anon-scaleway-ams',
  ] },
  { server_name = 'meganerd', via = [
    'anon-scaleway',
    'anon-tiarap',
  ] },
  { server_name = 'publicarray-au', via = [
    'anon-ibksturm',
    'anon-tiarap',
  ] },
  { server_name = 'scaleway-ams', via = [
    'anon-scaleway',
    'anon-meganerd',
  ] },
  { server_name = 'scaleway-fr', via = [
    'anon-meganerd',
    'anon-v.dnscrypt.uk-ipv4',
  ] },
  { server_name = 'v.dnscrypt.uk-ipv4', via = [
    'anon-scaleway',
    'anon-meganerd',
  ] },
]
```

- Edit `/etc/resolv.conf` :

```
nameserver 127.0.0.1
options edns0 single-request-reopen
```

and for permanent `/etc/resolv.conf` file :

```bash
chattr +i /etc/resolv.conf
```

- Start service and add it ot the boot time :

```bash
sudo systemctl start dnscrypt-proxy
sudo systemctl enable dnscrypt-proxy
```

<br>

### [OPTIONAL] dnsmasq : Configure `dnsmasq` as a local DNS cache

```bash
sudo pacman -S dnsmasq
```

Configure `Dnsmasq` in `vim /etc/dnsmasq.conf` uncomment lines and change to this :

```
no-resolv
server=::1#53
server=127.0.0.1#53
listen-address=::1,127.0.0.1
```

If you want enable DNS SECURE un comment these two line :

```
conf-file=/usr/share/dnsmasq/trust-anchors.conf
dnssec
```

and in dnscrypt-proxy config file in `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` uncomment `require-dnssec=true` to just select a dns resolver has DNSSEC extension.

- Start service and add it to the boot time

```bash
systemctl start dnsmasq
systemctl enable dnsmasq
```

<br>

### Bunch of useful utilities:

```bash
sudo pacman -S dbus              # Message bus used by many applications
sudo pacman -S intel-ucode       # Microcode update files for Intel CPUs
sudo pacman -S fuse2             # Interface for programs to export a filesystem to the Linux kernel
sudo pacman -S lshw              # Provides detailed information on the hardware of the machine
sudo pacman -S powertop          # A tool to diagnose issues with power consumption and power management
sudo pacman -S inxi              # Full featured CLI system information tool
sudo pacman -S acpi              # Client for battery, power, and thermal readings

sudo pacman -S base-devel        # Basic tools to build Arch Linux packages
sudo pacman -S git               # Distributed version control system
sudo pacman -S zip               # Compressor/archiver for creating and modifying zipfiles
sudo pacman -S unzip             # For extracting and viewing files in .zip archives
sudo pacman -S htop              # Interactive CLI process viewer
sudo pacman -S tree              # A directory listing program

sudo pacman -S dialog            # A tool to display dialog boxes from shell scripts
sudo pacman -S reflector         # Script to retrieve and filter the latest Pacman mirror list
sudo pacman -S bash-completion   # Programmable completion for the bash shell

sudo pacman -S iw                # CLI configuration utility for wireless devices
sudo pacman -S wpa_supplicant    # A utility providing key negotiation for WPA wireless networks
sudo pacman -S tcpdump           # Powerful command-line packet analyzer
sudo pacman -S mtr               # Combines the functionality of traceroute and ping into one tool
sudo pacman -S net-tools         # Configuration tools for Linux networking
sudo pacman -S conntrack-tools   # Userspace tools to interact with the Netfilter tracking system
sudo pacman -S ethtool           # Utility for controlling network drivers and hardware
sudo pacman -S wget              # Network utility to retrieve files from the Web
sudo pacman -S rsync             # File copying tool for remote and local files
sudo pacman -S socat             # Multipurpose socket relay
sudo pacman -S openbsd-netcat    # Netcat program. OpenBSD variant.
sudo pacman -S axel              # Light command line download accelerator
sudo pacman -S bind              # DNS server, but I install it because of dig utility
```

<br>

### Mount NTFS partition

- Use `lsblk -f` to find UUID of your partition .
- Then in `/etc/fstab` add :

```
UUID=YOUR-UUID  /mnt/[name]  ntfs3  uid=1000,gid=1000,force  0  0
```

<br>

### Install fonts

- Copy fonts in `~/.fonts` directory and then run:

```bash
fc-cache -fv
```

- List all fonts installed :

```bash
fc-list
```

<br>

### Handle passwords using `pass`

- Install packages :

```bash
sudo pacman -S pass pass-otp zbar
```

#### For initializing keys and pass (first time)

```bash
gpg --full-gen-key

# 1) RSA
# 2) 4096 bits
# 3) 0 -> to not expire
```

- Verify your setup with check that GPG lists :

```bash
gpg --list-keys
```

- Initialize pass

```bash
pass init <YOURKEYID:is_usually_the_last_8–16_chars_of_your_GPG_key>


# pass has built-in git support. Initialize:
# pass git init
# Then you can version and sync passwords:
# pass git add -A
# pass git commit -m "Added Gmail"
# pass git push
```

#### Usage

- Pass stores entries in `~/.password-store/`
- They are GPG-encrypted .gpg files, structured like directories.
- Insert a new password :

```bash
pass insert email/gmail
```

- View passwords :

```bash
pass email/gmail

# Copy password to clipboard for 45s:
pass -c email/gmail
```

- Edit & remove :

```bash
pass edit email/gmail

pass rm email/gmail
```

- Generate passwords :

```bash
# Generate password with 16 char length with symbols:
pass generate amazon 16 -s
```

- Search entries:

```bash
pass find gmail
```

- Show pass tree :

```bash
pass
```

- A menu for quickly get pass :

```bash
passmenu
```

- **pass otp :**
  - To add an otp, first you need URI. you can get it from QR-Code :

  ```bash
  zbarimg -q qrcode.png
  ```

  - Then you can add it to pass otp :

  ```bash
  pass otp add myGmailOtp
  ```

  - To see and check the otp URI :

  ```bash
  pass myGmailOtp
  ```

  - To get otp code :

  ```bash
  pass otp myGmailOtp
  ```

#### To export keys and pass :

- 1. Password store directory :

```bash
~/.password-store/

# Copy your password store
# tar czf pass-backup.tar.gz ~/.password-store
```

- 2. Export your GPG keys :

```bash
gpg --output public.gpg --armor --export <gpg_key_email_address_or_id>
gpg --output private.gpg --armor --export-secret-key <gpg_key_email_address_or_id>
```

#### To import keys and pass :

- Import your GPG keys:

```bash
gpg --import my-public.key
gpg --import my-private.key
```

- Then set trust:

```bash
# gpg --list-keys

gpg --edit-key YOURKEYID

trust
# 5 = ultimate trust (safe if it’s your own key).
# 4 = full trust.

save
```

- Restore your password store:

```bash
tar xzf pass-backup.tar.gz -C ~
```

- Initialize pass with your key:

```bash
pass init YOURKEYID
```

### Create a clean GPT partition

- First, identify your USB device:

```bash
lsblk
```

- Remove all partition tables and signatures :

```bash
sudo wipefs -a /dev/sdb
sudo sgdisk --zap-all /dev/sdb
sudo dd if=/dev/zero of=/dev/sdb bs=1M count=100 status=progress
```

- If `sgdisk` is not installed:

```bash
sudo pacman -S gptfdisk
```

- Create a new GPT partition table :

```bash
sudo parted /dev/sdb -- mklabel gpt
```

- Create one partition occupying the whole drive :

```bash
sudo parted -a optimal /dev/sdb -- mkpart primary 0% 100%
```

- For **NTFS** partition :

  ```bash
  sudo pacman -S ntfsprogs
  ```

  - Format the partition :

  ```bash
  mkfs.ntfs -f /dev/sdb1
  ```

- For **exFAT** partition :

  ```bash
  sudo pacman -S exfatprogs
  ```

  - Format the partition :

  ```bash
  sudo mkfs.exfat -n USB /dev/sdb1
  ```
