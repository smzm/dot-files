# My Arch Linux Dotfiles

Personal **Arch Linux dotfiles and installation setup**, focused on a keyboard-driven Wayland desktop using **Hyprland**, **Waybar**, **Neovim**, and other command-line tools.

The repository also contains configuration and installation instructions for **Arch Linux on WSL**.

---

# Installation

## Arch Linux

Clone the repository:

```bash
git clone https://github.com/smzm/dot-files.git
cd dot-files
```

Run the installer:

```bash
./dotfile-installer.sh
```

The installer handles package installation and configuration deployment.


---

## Arch Linux on WSL

### 1. Install Arch Linux

First, update WSL from Windows:

```powershell
wsl.exe --update
```

Then install Arch Linux:

```powershell
wsl --install archlinux
```

Start Arch Linux:

```powershell
wsl -d archlinux
```

---

### 2. Set Arch Linux as the Default WSL Distribution

From a Windows shell:

```powershell
wsl --set-default Arch
```

You can verify the installed distributions with:

```powershell
wsl --list --verbose
```

---

### 3. Initialize Pacman

Inside Arch Linux, initialize and populate the Pacman keyring:

```bash
sudo pacman-key --init
sudo pacman-key --populate
```

Update the Arch Linux keyring:

```bash
sudo pacman -Sy archlinux-keyring
```

Then update the system:

```bash
sudo pacman -Syyu --noconfirm
```

---

### 4. Create a User

Install `sudo`:

```bash
pacman -S sudo
```

Create the `sudo` group:

```bash
groupadd sudo
```

Enable sudo access for the `wheel` group:

```bash
sed -i '/^#.*%wheel ALL=(ALL:ALL) ALL/s/^#//' /etc/sudoers
```

Create your user:

```bash
useradd -m -G wheel,sudo -s /bin/bash <username>
passwd <username>
```

Switch to the new user:

```bash
su - <username>
```

> Replace `<username>` with the username you want to use.

---

### 5. Set the Default WSL User

From a Windows shell, set your newly created user as the default WSL user:

```powershell
wsl --manage archlinux --set-default-user <username>
```

---

### 6. Install the Dotfiles

Install the required base packages:

```bash
sudo pacman -S git --noconfirm --needed
```

Clone the repository:

```bash
git clone https://github.com/smzm/dot-files.git
cd dot-files
```

Run the installer:

```bash
./install.sh
```

The installer will let you select the sections and packages you want to install.

---

## Windows Terminal

If you are using Arch Linux through WSL, you can optionally configure Windows Terminal to match the setup.

See:

```text
windowsTerminal/readme.md
```

---


# License

Use, modify, and adapt anything here as you like.
