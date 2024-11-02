# . FILES

<br>

![image](https://user-images.githubusercontent.com/39596095/219023272-8f32a8fa-8c46-4070-8a99-3ade69911b55.png)

## Installing in `Arch` : 
```shell
sudo pacman -S python python-pip git --noconfirm --needed
git clone https://github.com/smzm/mydotfiles.git
cd mydotfiles     # always run the script from this directory
```

and Use `dotfile_installation.py` python file for installing programms and dotfiles.

<br>

### Autostart programs when reboot (Optional)
- Add to the `/etc/systemd/system/vpn.service` :
```
[Unit]
Description=vpn
After=network-online.target
Wants=network-online.target


[Service]
ExecStart=/home/rodd/Desktop/vpn.sh
Environment=DISPLAY=:0
Restart=always


[Install]
WantedBy=multi-user.target
```
- run `sudo systemctl daemon-reload` and `sudo systemctl enable vpn.service`
- If your service could not access to the display create `~/.xprofile` and add `xhost +SI:localuser:root` to it to give access the root user to display manager.



<br>
<br>


# Installing in `WSL` :
- [WSL installation guide for yuk7/ArchWSL](https://learn.microsoft.com/en-us/windows/wsl/install-manual)
- ### 1. Install ArchWsl 
  - Update wsl in windows : `wsl.exe --update`
  - Download [yuk7/ArchWSL](https://github.com/yuk7/ArchWSL) installer zip, pick a folder and run `arch.exe` in that folder.



- ### 2. Refresh Pacman GPG keys:
```bash
sudo pacman-key --init
sudo pacman-key --populate
# sudo pacman-key --refresh-keys
sudo pacman -Sy archlinux-keyring
pacman -Syyu --noconfirm
```

- ### 3. Add user
```shell
groupadd sudo
sed -i '/^#.*%wheel ALL=(ALL:ALL) ALL/s/^#//' /etc/sudoers
```
```shell
useradd -m -G wheel,sudo -s /bin/bash <username>
passwd <username>
su <username> ; cd ~
```
> Change `<username>` too whatever you want.
  
- ### 4. Install needed packages
```shell
sudo pacman -S python python-pip git --noconfirm --needed
git clone https://github.com/smzm/mydotfiles.git
```

- ### 5. Install through `dotfile_installation.py`
```bash
cd mydotfiles   # You must first change directory to 'mydotfiles' and then run the python code to work properly.
python dotfile_installation.py
```

> After running `dotfile_installation.py` if you don't have needed packages script install it automatically but you will encounter with an `NameError` about `inquirer` package. to resolve the issue run script again with `python dotfile_installation.py`.

- ### 6. Setting ArchLinux as default WSL
Just run `wsl --set-default Arch` in windows command shell.

- ### 7. Setting default user in `Arch` 
To setting default user in windows command shell got to the arch direcctory and run : `Arch.exe config --default-user <username>`

- ### 8. Config Windows Terminal [optional]
Config you windows terminal settings like [this](./windowsTerminal/readme.md)

- ### 9. Enable systemd
If you’re using WSL 0.67.6 and above (see `wsl --version`), systemd is natively supported. To enable it, edit `/etc/wsl.conf` and then restart the distro.
```conf
[boot]
systemd=true
```

- ### 10. DNS Settings
1. Disable regenrating `reslvconf` in `/etc/wsl.conf` :
```conf
[network]
generateResolvConf = false
```

2. Create a file with the name : `/etc/systemd/resolved.conf.d/10-cloudflare.conf`
```conf
DNS=1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001
```
enable and restart `resolved` : 
`sudo systemctl enable systemd-resolved.service`
`sudo systemctl restart systemd-resolved.service`

<br>
<br>

## Neovim installation 
After installing Neovim : 

For importing pip packages in `pylsp` : 
- open `~/.local/share/nvim/mason/packages/python-lsp-server/venv/pyvenv.cfg` and set `include-system-site-packages = true `
