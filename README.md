# . FILES

<br>

![image](https://user-images.githubusercontent.com/39596095/219023272-8f32a8fa-8c46-4070-8a99-3ade69911b55.png)

## Installing in `Arch` :

```shell
sudo pacman -S python python-pip git --noconfirm --needed
git clone https://github.com/smzm/dot-files.git
cd dot-files     # always run the script from this directory
```

and Use `dotfile_installation.py` python file for installing programms and dotfiles.

<br>
<br>

# Installing in `WSL` :

- ### 1. Install ArchWsl
  - Update wsl in windows : `wsl.exe --update`
  - Run the following command in a Windows shell:

```bash
 wsl --install archlinux
```

- ### 2. Setting ArchLinux as default WSL

  Just run `wsl --set-default Arch` in windows command shell.

- ### 2. Refresh Pacman GPG keys:

```bash
sudo pacman-key --init
sudo pacman-key --populate
# sudo pacman-key --refresh-keys
sudo pacman -Sy archlinux-keyring
pacman -Syyu --noconfirm
```

- ### 3. Add user

```bash
pacman -S sudo
```

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

- ### 4. Setting default user in `Arch`

  To setting default user in windows command shell got to the arch direcctory and run : `wsl --manage archlinux --set-default-user <username>`

- ### 5. Installing

```shell
sudo pacman -S python python-pip git --noconfirm --needed
git clone https://github.com/smzm/dot-files.git
cd dot-files
```

- After running `dotfile_installation.py` you will encounter with an `NameError` about `inquirer` and `rich` package. to resolve the issue :

```bash
python -m venv .venv
source .venv/bin/activate
pip install inquirer rich
python dotfile_installation.py
```

- ### 6. Config Windows Terminal [optional]

  Config you windows terminal settings like [this](./windowsTerminal/readme.md)

## Installing in Arch Linux :

- [Use this doc for installing Arch linux](./arch-installation.md)
