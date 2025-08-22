import os
import re
import subprocess
from subprocess import DEVNULL, PIPE, STDOUT, run

import inquirer
from rich.console import Console

console = Console()
from rich import print as rprint
from rich.columns import Columns

# ===== Get path of dotfiles directory
dotfiles_path = os.popen("echo $PWD").read().rstrip()

# ===== Is it WSL or Arch
os_q = [
    inquirer.List(
        "interest",
        message="Install in WSLArch or Arch",
        choices=["WSL", "Arch"],
    )
]
os_answers = inquirer.prompt(os_q)
subprocess.run("clear", shell=True)


# ===== Update pacman mirrorlist
reflector_q = [
    inquirer.List(
        "interest",
        message="Do you want to update pacman mirrorlist",
        choices=["No", "Yes"],
    )
]
reflector_answer = inquirer.prompt(reflector_q)
if reflector_answer["interest"] == "Yes":
    country_q = [
        inquirer.Text(
            "interest",
            message="Which country or countries, you prefer to use in pacman mirrorlist",
        )
    ]
    country_answer = inquirer.prompt(country_q)
    subprocess.run(
        "sudo pacman -S reflector rsync curl --noconfirm --needed", shell=True
    )
    subprocess.run(
        "sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak", shell=True
    )
    rprint(f"\n[italic yellow] Rating mirrors in {country_answer['interest']}...\n")
    subprocess.run(
        f"sudo reflector -c '{country_answer['interest']}' --sort rate --save /etc/pacman.d/mirrorlist",
        shell=True,
    )


# ===== Update pacman packages
subprocess.run("sudo pacman -Syu --noconfirm", shell=True)

print("\n")

if os_answers["interest"] == "Arch":
    # ===== Install pacman packages : ARCH
    pacman_list = [
        "git",
        "wget",
        "yajl",
        "curl",
        "binutils",
        "network-manager-applet",
        "networkmanager-openvpn",
        "lightdm",
        "lightdm-gtk-greeter",
        "openssh",
        "zsh",
        "nodejs",
        "npm",
        "yarn",
        "ruby",
        "python",
        "rust",
        "python-pip",
        "jupyter-notebook",
        "python-ipykernel",
        "pyenv",
        "neovim",
        "xclip",
        "python-pynvim",
        "cronie",
        "lsd",
        "tmux",
        "aria2",
        "lf",
        "unarchiver",
        "ripgrep",
        "peco",
        "lostfiles",
        "github-cli",
        "tree-sitter-cli",
        "tldr",
        "kitty",
        "zathura",
        "zathura-pdf-mupdf",
        "mpv",
        "mpv-mpris",
        "xbindkeys",
        "xorg-xev",
        "xdotool",
        "nautilus",
        "lxappearance",
        "nitrogen",
        "viewnior",
        "gtk3",
        "ntfs-3g",
        "exfat-utils",
        "i3-gaps",
        "python-i3ipc",
        "arandr",
        "rofi",
        "python-pywal",
        "calc",
        "bc",
        "wmctrl",
        "geoip",
        "dunst",
        "libnotify",
        "redshift",
        "imwheel",
        "numlockx",
        "unclutter",
        "fzy",
        "mediainfo",
        "xcolor",
        "conky",
        "pulseaudio",
        "pulseaudio-alsa",
        "pulseaudio-equalizer",
        "pulseaudio-jack",
        "pulseaudio-bluetooth",
        "alsa-utils",
        "alsa-firmware",
        "xdg-desktop-portal",
        "xdg-desktop-portal-gtk",
        "pavucontrol",
        "bluez",
        "bluez-utils",
        "unrar",
        "unzip",
        "tar",
        "htop",
        "mtpfs",
        "gvfs-mtp",
        "gvfs-gphoto2",
        "ttf-firacode-nerd",
        "starship",
        "gnome-keyring",
        "inter-font",
        "usbutils",
        "lldb",
        "ttf-jetbrains-mono",
        "blueman",
        "udisks2",
        "udiskie",
        "ollama-cuda",
        "yt-dlp",
        "inter-font",
        "obsidian",
        "docker",
        "docker-compose",
        "telegram-desktop",
        "uv",
        "ruff",
        "file-roller",
        "ocrdesktop",
        "tesseract-data-eng",
        "lazygit",
        "ripgrep",
        "ffmpeg",
        "ffmpegthumbnailer",
        "p7zip",
        "jq",
        "poppler",
        "fd",
        "fzf",
        "zoxide",
        "imagemagick",
        "bat",
        "newsboat",
        "eza",
        "playerctl",
        "luarocks",
        "python-pillow",
        "python-cairosvg",
        "python-plotly",
    ]

elif os_answers["interest"] == "WSL":
    # ===== Install pacman packages : WSL
    pacman_list = [
        "base-devel",
        "binutils",
        "pkgconf",
        "python",
        "python-pip",
        "python-ipykernel",
        "python-pynvim",
        "pyenv",
        "nodejs",
        "npm",
        "yarn",
        "git",
        "wget",
        "binutils",
        "openssh",
        "zsh",
        "starship",
        "tmux",
        "ruby",
        "rust",
        "jupyter-notebook",
        "github-cli",
        "tree-sitter-cli",
        "neovim",
        "lsd",
        "aria2",
        "tldr",
        "unrar",
        "unzip",
        "tar",
        "dnscrypt-proxy",
        # "xclip",
        "xsel",
        "xdg-utils",
        "lldb",
        "ruff",
        "uv",
        "lazygit",
        "ripgrep",
        "ffmpeg",
        "ffmpegthumbnailer",
        "p7zip",
        "jq",
        "poppler",
        "fd",
        "fzf",
        "zoxide",
        "imagemagick",
        "bat",
        "newsboat",
        "eza",
        "luarocks",
        "python-pillow",
        "python-cairosvg",
        "python-plotly",
    ]


pacman_packages_q = [
    inquirer.Checkbox(
        "interest",
        message="What packages do you want to install [SELECT WITH SPACE]",
        choices=["ALL ⬇️", *pacman_list],
    )
]
pacman_packages_answers = inquirer.prompt(pacman_packages_q)

not_installed_packages_pacman = []
installed_packages_pacman = []


if "ALL ⬇️" in pacman_packages_answers["interest"]:
    rprint("[bold blue] Installing all packages :")
    rprint(Columns(pacman_list, equal=True, expand=True))
    for package in pacman_list:

        rprint(f"\n[yellow italic] installing {package}...")
        pacman_result = subprocess.run(
            f"sudo pacman -S {package} --noconfirm",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        # if package installed successfuly
        if pacman_result.returncode == 0:
            rprint(f"[bold green] {package} : [italic] installed.")
            installed_packages_pacman.append(package)
        # if package not installed successfuly
        else:
            rprint(
                f"[bold white] {package} : [red] There was a problem in installing this package."
            )
            not_installed_packages_pacman.append(package)
    print("\n")


else:
    rprint("[italic salmon1] Installing selected packages :")
    rprint(Columns(pacman_packages_answers["interest"], equal=True, expand=True))

    for package in pacman_packages_answers["interest"]:
        rprint(f"\n[yellow italic] installing {package}...")
        pacman_result = subprocess.run(
            f"sudo pacman -S {package} --noconfirm --needed",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        # if package installed successfuly
        if pacman_result.returncode == 0:
            rprint(f"[bold green] {package} : [italic] installed.")
            installed_packages_pacman.append(package)
        # if package not installed successfuly
        else:
            not_installed_packages_pacman.append(package)
            pacman_stderr = pacman_result.stderr.decode().strip()
            # Problem  : package does not exist
            if re.search(r"target not found", pacman_stderr):
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. couldn't find this package !"
                )
            elif re.search(r"slow connection", pacman_stderr):
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. Connection is slow. try again !"
                )
            else:
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. There was a problem in installing this package !"
                )
    print("\n")


# If there is any not installed packae then ask for try again
while len(not_installed_packages_pacman) > 0:
    print("\n")
    not_installed_pacman_q = [
        inquirer.List(
            "interest",
            message="Do you want to try again and install packges was not installed successfully",
            choices=["No", "Yes"],
        )
    ]
    not_installed_pacman_answer = inquirer.prompt(not_installed_pacman_q)
    if not_installed_pacman_answer["interest"] == "Yes":
        rprint("[italic salmon1] Installing selected packages :")
        rprint(Columns(not_installed_packages_pacman, equal=True, expand=True))
        for package in not_installed_packages_pacman:
            rprint(f"\n[yellow italic] installing {package}...")
            pacman_result = subprocess.run(
                f"sudo pacman -S {package} --noconfirm",
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            # if package installed successfuly
            if pacman_result.returncode == 0:
                rprint(f"[bold green] {package} : [italic] installed.")
                installed_packages_pacman.append(package)
                not_installed_packages_pacman.remove(package)
            else:
                pacman_stderr = pacman_result.stderr.decode().strip()
                # Problem  : package does not exist
                if re.search(r"target not found", pacman_stderr):
                    rprint(
                        f"[bold white] {package} : [red italic] NOT INSTALLED. couldn't find this package !"
                    )
                # Problem  : package internet connection is slow
                elif re.search(r"slow connection", pacman_stderr):
                    rprint(
                        f"[bold white] {package} : [red italic] NOT INSTALLED. Connection is slow. try again !"
                    )
                else:
                    rprint(
                        f"[bold white] {package} : [red italic] NOT INSTALLED. There was a problem in installing this package !"
                    )
    # If there isn't not installed package break the while and go on
    else:
        break


# ===== Install dnsmasq and 403Online
doh_config = [
    inquirer.List(
        "interest", message="Install dnsmasq and 403.Online", choices=["No", "Yes"]
    )
]
doh_config_answer = inquirer.prompt(doh_config)

if doh_config_answer["interest"] == "Yes":
    subprocess.run("clear", shell=True)
    pacman_result = subprocess.run(
        "sudo pacman -S dnsmasq --noconfirm",
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if pacman_result.returncode == 0:
        os.system(f"sudo cp -f {dotfiles_path}/etc/dnsmasq.conf /etc/dnsmasq.conf")

        if os_q == "WSL":
            os.system("sudo systemctl start dnsmasq ; sudo systemctl enable dnsmasq")
            os.system(
                "sudo systemctl enable systemd-resolved ; sudo systemctl start systemd-resolved"
            )
            os.system(
                r"sudo grep -q '^\[Resolve\]' /etc/systemd/resolved.conf && ! grep -q '^DNS=127.0.0.1:5353' /etc/systemd/resolved.conf && sudo sed -i '/^\[Resolve\]/a DNS=127.0.0.1:5353' /etc/systemd/resolved.conf"
            )
            os.system(
                "sudo grep -q '^port 5353$' /etc/dnsmasq.conf || sudo sed -i '/#DNS PORT/!b;n;/^port 5353$/b;a port=5353' /etc/dnsmasq.conf"
            )

        if os_q == "ARCH":
            os.system(
                "sudo systemctl disable systemd-resolved ; sudo systemctl stop systemd-resolved"
            )
            os.system("sudo systemctl start dnsmasq ; sudo systemctl enable dnsmasq")

            # remove /etc/resolve.conf
            os.system("sudo chattr -i /etc/resolv.conf")
            os.system("sudo rm -rf /etc/resolv.conf")
            os.system(
                "sudo grep -qxF '[main]' /etc/NetworkManager/NetworkManager.conf || echo -e '[main]\ndns=dnsmasq' | sudo tee -a /etc/NetworkManager/NetworkManager.conf"
            )
            os.system("sudo systemctl restart NetworkManager")

        print("\n")
    else:
        rprint("[red italic] dnsmasq could not installed.\n")


# ===== Arch community packages : Paru
paru_check = run("paru --version", shell=True, stdout=PIPE, stderr=STDOUT)
if paru_check.returncode == 0:
    rprint(":thumbs_up: [bold light_pink3] paru is installed.")
# If paru was not installed
else:
    rprint("[italic yellow] Installing paru...")
    os.system("sudo pacman -S --needed base-devel")
    os.system("cd ~ ; git clone https://aur.archlinux.org/paru.git")
    os.system("cd ~/paru ; makepkg -si")
    os.system("cd ~ ; rm -rf paru")


# ===== Install aur packages
subprocess.run("clear", shell=True)

if os_answers["interest"] == "Arch":
    # ===== Install aur packages : Arch
    aur_list = [
        #'xbindkeys_config-gtk2',
        #'clipit',
        # "udevil",
        "tailwindcss",
        "tailwindcss-language-server",
        "picom",
        "polybar",
        "pacman-contrib",
        "cava",
        "ttf-indic-otf",
        "spotify",
        "sptlrx-bin",
        "i3-scrot",
        "ttf-poppins",
        "apple-fonts",
        "ttf-font-awesome",
        "ttf-estedad-variable",
        "noto-fonts-emoji",
        "pulseaudio-ctl",
        "jmtpfs",
        "flatplat-blue-theme",
        "apple_cursor",
        "ttf-poppins",
        "i3exit",
        "visual-studio-code-bin",
        "emoji-keyboard-bin",
        "yazi",
        "trashy",
        "python-jupytext",
        "pnglatex",
    ]
elif os_answers["interest"] == "WSL":
    # ===== Install aur packages : WSL
    aur_list = [
        "manim",
        "yazi",
        "trashy",
        "python-jupytext",
        "pnglatex",
    ]


aur_packages_q = [
    inquirer.Checkbox(
        "interest",
        message="What aur packages do you want to install [SELECT WITH SPACE]",
        choices=["ALL ⬇️", *aur_list],
    )
]
aur_packages_answers = inquirer.prompt(aur_packages_q)


not_installed_packages_aur = []
installed_packages_aur = []
if "ALL ⬇️" in aur_packages_answers["interest"]:
    rprint("[bold blue] Installing all packages :")
    rprint(Columns(aur_list, equal=True, expand=True))
    for package in aur_list:
        rprint(f"\n[yellow italic] installing {package}...")
        aur_result = subprocess.run(
            f"paru -S {package} --noconfirm --needed",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        # if package installed successfuly
        if aur_result.returncode == 0:
            rprint(f"[bold green] {package} : [italic] installed.")
            installed_packages_aur.append(package)
        # if package not installed successfuly
        else:
            rprint(
                f"[bold white] {package} : [red] There was a problem in installing this package."
            )
            not_installed_packages_aur.append(package)
    print("\n")

else:
    rprint("[italic salmon1] Installing selected packages :")
    rprint(Columns(aur_packages_answers["interest"], equal=True, expand=True))
    for package in aur_packages_answers["interest"]:
        rprint(f"\n[yellow italic] installing {package}...")
        aur_result = subprocess.run(
            f"paru -S {package} --noconfirm",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        # if package installed successfuly
        if aur_result.returncode == 0:
            rprint(f"[bold green] {package} : [italic] installed.")
            installed_packages_aur.append(package)
        # if package not installed successfuly
        else:
            not_installed_packages_aur.append(package)
            aur_stderr = aur_result.stderr.decode().strip()
            # Problem  : package does not exist
            if re.search(r"could not find all required packages", aur_stderr):
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. couldn't find this package !"
                )
            else:
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. There was a problem in installing this package !"
                )
    print("\n")

# If there is any not installed packae then ask for try again
while len(not_installed_packages_aur) > 0:
    print("\n")
    not_installed_aur_q = [
        inquirer.List(
            "interest",
            message="Do you want to try again and install aur packges was not installed successfully",
            choices=["No", "Yes"],
        )
    ]
    not_installed_aur_answer = inquirer.prompt(not_installed_aur_q)

    if not_installed_aur_answer["interest"] == "Yes":
        rprint("[italic salmon1] Installing selected packages :")
        rprint(Columns(not_installed_packages_aur, equal=True, expand=True))
        for package in not_installed_packages_aur:
            rprint(f"\n[yellow italic] installing {package} :")
            aur_result = subprocess.run(
                f"paru -S {package} --noconfirm",
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            # if package installed successfuly
            if aur_result.returncode == 0:
                rprint(f"[bold green] {package} : [italic] installed.")
                installed_packages_aur.append(package)
                not_installed_packages_aur.remove(package)
            else:
                aur_stderr = aur_result.stderr.decode().strip()
                # Problem  : package does not exist
                if re.search(r"could not find all required packages", aur_stderr):
                    rprint(
                        f"[bold white] {package} : [red italic] NOT INSTALLED. couldn't find this package !"
                    )
                else:
                    rprint(
                        f"[bold white] {package} : [red italic] NOT INSTALLED. There was a problem in installing this package !"
                    )
    # If there isn't not installed package break the while and go on
    else:
        break


subprocess.run("clear", shell=True)


# ===== Node configuration
npm_result1 = subprocess.run(
    "npm --version", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
)
if npm_result1.returncode == 0:
    npm_result2 = subprocess.run(
        "mkdir -p ~/.npm", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    npm_result3 = subprocess.run(
        "npm config set prefix ~/.npm",
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if npm_result1 and npm_result2:
        rprint(":thumbs_up: [bold green] npm is installed and configured.")


# ===== Npm packages
npm_packages_list = [
    "pyright",
    "vim-language-server",
    "vscode-langservers-extracted",
    "typescript",
    "typescript-language-server",
    "awk-language-server",
    "dockerfile-language-server-nodejs",
    "emmet-ls",
    "bash-language-server",
    "yaml-language-server",
    "neovim",
    "tree-sitter",
    "biome",
    "prettier",
]
npm_package = [
    inquirer.Checkbox(
        "interest",
        message="Install npm packages [SELECT WITH SPACE]",
        choices=["ALL ⬇️", *npm_packages_list],
    ),
]
npm_package_answers = inquirer.prompt(npm_package)


not_installed_packages_npm = []
installed_packages_npm = []
if "ALL ⬇️" in npm_package_answers["interest"]:
    rprint("[bold blue] Installing all npm packages :")
    rprint(Columns(npm_packages_list, equal=True, expand=True))

    for package in npm_packages_list:
        rprint(f"\n[yellow italic] installing {package}...")
        npm_result = subprocess.run(
            f"npm install -g {package}",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        # if npm package installed successfuly
        if npm_result.returncode == 0:
            rprint(f"[bold green] {package} : [italic] installed.")
            installed_packages_npm.append(package)
        # if npm package not installed successfuly
        else:
            not_installed_packages_npm.append(package)
            npm_stderr = npm_result.stderr.decode().strip()
            # Problem  : package does not exist
            if re.search(r"code E404", npm_stderr):
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. couldn't find this package !"
                )
            else:
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. There was a problem in installing this package !"
                )

    print("\n")
else:
    rprint("[italic salmon1] Installing selected packages :")
    rprint(Columns(npm_package_answers["interest"], equal=True, expand=True))

    for package in npm_package_answers["interest"]:
        rprint(f"\n[yellow italic] installing {package}...")
        npm_result = subprocess.run(
            f"npm install -g {package}",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        # if npm package installed successfuly
        if npm_result.returncode == 0:
            rprint(f"[bold green] {package} : [italic] installed.")
            installed_packages_npm.append(package)
        # if npm package not installed successfuly
        else:
            not_installed_packages_npm.append(package)
            npm_stderr = npm_result.stderr.decode().strip()
            # Problem  : package does not exist
            if re.search(r"code E404", npm_stderr):
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. couldn't find this package !"
                )
            else:
                rprint(
                    f"[bold white] {package} : [red italic] NOT INSTALLED. There was a problem in installing this package !"
                )


# If there is any not installed packae then ask for try again
while len(not_installed_packages_npm) > 0:
    print("\n")
    not_installed_npm_q = [
        inquirer.List(
            "interest",
            message="Do you want to try again and install npm packges was not installed successfully",
            choices=["No", "Yes"],
        )
    ]
    not_installed_npm_answer = inquirer.prompt(not_installed_npm_q)
    if not_installed_npm_answer["interest"] == "Yes":
        rprint("[italic salmon1] Installing selected packages :")
        rprint(Columns(not_installed_packages_npm, equal=True, expand=True))

        for package in not_installed_packages_npm:
            rprint(f"\n[yellow italic] installing {package}...")
            npm_result = subprocess.run(
                f"npm install -g {package}",
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )

            # if npm package installed successfuly
            if npm_result.returncode == 0:
                rprint(f"[bold green] {package} : [italic] installed.")
                installed_packages_npm.append(package)
                not_installed_packages_npm.remove(package)
            else:
                npm_stderr = npm_result.stderr.decode().strip()
                # Problem  : package does not exist
                if re.search(r"code E404", npm_stderr):
                    rprint(
                        f"[bold white] {package} : [red italic] NOT INSTALLED. couldn't find this package !"
                    )
                else:
                    rprint(
                        f"[bold white] {package} : [red italic] NOT INSTALLED. There was a problem in installing this package !"
                    )

    # If there isn't not installed package, break the while and go on
    else:
        break


subprocess.run("clear", shell=True)


# ===== ZSH configuration
zsh_config = [
    inquirer.List(
        "interest",
        message="Install OH-MY-ZSH and their configurations",
        choices=["No", "Yes"],
    ),
]
zsh_config_answer = inquirer.prompt(zsh_config)

if zsh_config_answer["interest"] == "Yes":
    rprint("[bold italic] ZSH Configuration : ")
    # OH-MY-ZSH
    os.system(
        'sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    )
    #  zsh-syntax-highlighting
    os.system(
        "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    )
    #  zsh-auto-suggestions
    os.system(
        "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    )
    #  fzf
    os.system(
        "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf ; ~/.fzf/install"
    )
    os.system("chsh -s $(which zsh)")
    #  Starship
    starship_result = run("starship --version", shell=True, stdout=PIPE, stderr=STDOUT)
    if starship_result.returncode == 0:
        # os.system('curl -sS https://starship.rs/install.sh | sh')
        os.system(f"yes | cp -rf {dotfiles_path}/.config/starship.toml ~/.config/")
    # if starship was not installed
    else:
        rprint(":thumbs_down: [bold light_pink3] Starship is not installed.")

    # zshrc
    os.system(f"yes | cp -rf {dotfiles_path}/.zshrc ~/")
    os.system(f"yes | cp -rf {dotfiles_path}/.zshenv ~/")
    os.system("source ~/.zshrc")

subprocess.run("clear", shell=True)


# ===== Neovim Installation
neovim_check = (
    subprocess.run(
        "nvim --version", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    ).returncode
    == 0
)
if neovim_check:
    rprint(":thumbs_up: [green] Neovim is installed.")

    nvim_config = [
        inquirer.List(
            "interest",
            message="Install Neovim configurations",
            choices=["No", "Yes"],
        ),
    ]
    nvim_config_answer = inquirer.prompt(nvim_config)

    if nvim_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        # VIM-PLUG
        subprocess.run(
            "sh -c 'curl -fLo \"${XDG_DATA_HOME:-$HOME/.local/share}\"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        neovim1 = subprocess.run(
            "mkdir -p ~/.config/nvim",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        neovim2 = subprocess.run(
            f"yes | cp -rf {dotfiles_path}/.config/nvim/* ~/.config/nvim/",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if neovim1 and neovim2:
            rprint("[italic light_pink3] Installing Neovim Plugins ...")
            subprocess.run('nvim +"PlugInstall --sync" +qa', shell=True)
else:
    rprint(":thumbs_down: [red italic] neovim is not installed.\n")

subprocess.run("clear", shell=True)


# ===== opencode
opencode_config = [
    inquirer.List(
        "interest",
        message="Install OpenCode and their configurations",
        choices=["No", "Yes"],
    ),
]
opencode_answer = inquirer.prompt(opencode_config)

if opencode_answer["interest"] == "Yes":
    rprint("[bold italic] OpenCode Configuration : ")
    # Installation
    os.system("curl -fsSL https://opencode.ai/install | bash")

    # OpenCode Configuration
    os.system(f"yes | cp -rf {dotfiles_path}/.config/opencode ~/.config/opencode")

subprocess.run("clear", shell=True)

# ===== Yazi : filemanager configuration
yazi_check = (
    subprocess.run(
        "yazi --version", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    ).returncode
    == 0
)
if yazi_check:
    rprint(":thumbs_up: [green] Yazi is installed.")

    yazi_config = [
        inquirer.List(
            "interest",
            message="Install Yazi configurations",
            choices=["No", "Yes"],
        ),
    ]
    yazi_config_answer = inquirer.prompt(yazi_config)
    if yazi_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        yazi1 = subprocess.run(
            "mkdir -p ~/.config/yazi",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        yazi2 = subprocess.run(
            f"yes | cp -rf {dotfiles_path}/.config/yazi/* ~/.config/yazi/",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if yazi1 and yazi2:
            rprint("[italic light_pink3] Installing Yazi Plugins ...")
            subprocess.run(
                "cd ~/.config/yazi/ ; ya pkg add yazi-rs/plugins:full-border imsi32/yatline MasouShizuka/projects DreamMaoMao/fg AnirudhG07/plugins-yazi:copy-file-contents Lil-Dank/lazygit pirafrank/what-size",
                shell=True,
            )
else:
    rprint(":thumbs_down: [red italic] Yazi is not installed.\n")

subprocess.run("clear", shell=True)


# ===== newsboat : rss reader in terminal
newsboat_check = (
    subprocess.run(
        "newsboat --version", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    ).returncode
    == 0
)
if newsboat_check:
    rprint(":thumbs_up: [green] Newsboat is installed.")

    newsboat_config = [
        inquirer.List(
            "interest",
            message="Install Newsboat configurations",
            choices=["No", "Yes"],
        ),
    ]
    newsboat_config_answer = inquirer.prompt(newsboat_config)
    if newsboat_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        newsboat1 = subprocess.run(
            "mkdir -p ~/.config/newsboat",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        newsboat2 = subprocess.run(
            f"yes | cp -rf {dotfiles_path}/.config/newsboat/* ~/.config/newsboat/",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
else:
    rprint(":thumbs_down: [red italic] Newsboat is not installed.\n")

subprocess.run("clear", shell=True)


# ===== Font and language Configuration
if os_answers["interest"] == "Arch":
    font_config = [
        inquirer.List(
            "interest",
            message="Install font and language configurations",
            choices=["No", "Yes"],
        ),
    ]
    font_config_answer = inquirer.prompt(font_config)
    if font_config_answer["interest"] == "Yes":
        os.system(f"sudo cp {dotfiles_path}/etc/local.conf /etc/fonts/local.conf")
        os.system(f"sudo cp {dotfiles_path}/etc/00-keyboard.conf /etc/X11/xorg.conf.d/")
        # Install feather font
        os.system("mkdir -p $HOME/.fonts")
        os.system(f"yes | cp -rf {dotfiles_path}/.fonts/* $HOME/.fonts/")
        os.system("fc-cache -fv")


# ===== Tmux configuration
tmux_check = (
    subprocess.run(
        "tmux -V", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    ).returncode
    == 0
)
if tmux_check:
    rprint(":thumbs_up: [green] tmux is installed.")

    tmux_config = [
        inquirer.List(
            "interest",
            message="Install tmux configurations",
            choices=["No", "Yes"],
        ),
    ]
    tmux_config_answer = inquirer.prompt(tmux_config)

    if tmux_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        tmux_dir = subprocess.run(
            "mkdir -p ~/.config/tmux",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        run(
            f"yes | cp -rf {dotfiles_path}/.config/tmux ~/.config/",
            shell=True,
            stdout=DEVNULL,
        )
        os.system(
            "git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm"
        )

else:
    rprint(":thumbs_down: [red italic] tmux is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Gh configuration
githubcli_check = (
    subprocess.run(
        "gh --version", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    ).returncode
    == 0
)

if githubcli_check:
    rprint(":thumbs_up: [green] github-cli is installed.")

    githubcli_config = [
        inquirer.List(
            "interest",
            message="Install github-cli configurations",
            choices=["No", "Yes"],
        ),
    ]
    githubcli_config_answer = inquirer.prompt(githubcli_config)

    if githubcli_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        subprocess.run(
            "sudo systemctl start sshd.service ; sudo systemctl enable sshd.service",
            shell=True,
            stdout=DEVNULL,
        )
        os.system("gh auth login")

else:
    rprint("[red italic] github-cli is not installed.\n")


subprocess.run("clear", shell=True)

# ===== Kitty configuration
if os_answers["interest"] == "Arch":
    kitty_check = (
        subprocess.run(
            "kitty --version",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).returncode
        == 0
    )

    if kitty_check:
        rprint(":thumbs_up: [green] kitty is installed.")

        kitty_config = [
            inquirer.List(
                "interest",
                message="Install kitty configurations",
                choices=["No", "Yes"],
            )
        ]
        kitty_config_answer = inquirer.prompt(kitty_config)

        if kitty_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True, stdout=DEVNULL, stderr=DEVNULL)
            subprocess.run("mkdir -p ~/.config/kitty", shell=True, stdout=DEVNULL)
            subprocess.run(
                f"yes | cp -rf {dotfiles_path}/.config/kitty/* ~/.config/kitty/",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] kitty is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Zathura configuration
if os_answers["interest"] == "Arch":
    zathura_check = (
        subprocess.run(
            "zathura --version",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).returncode
        == 0
    )

    if zathura_check:
        rprint(":thumbs_up: [green] zathura is installed.")

        zathura_config = [
            inquirer.List(
                "interest",
                message="Install zathura configurations",
                choices=["No", "Yes"],
            ),
        ]
        zathura_config_answer = inquirer.prompt(zathura_config)

        if zathura_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run("mkdir -p ~/.config/zathura", shell=True, stdout=DEVNULL)
            run(
                f"yes | cp -rf {dotfiles_path}/.config/zathura/* ~/.config/zathura",
                shell=True,
                stdout=DEVNULL,
            )

    else:
        rprint("[red italic] kitty is not installed.\n")

subprocess.run("clear", shell=True)

# ===== mpv configuration
if os_answers["interest"] == "Arch":
    mpv_check = (
        subprocess.run(
            "mpv --version", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        ).returncode
        == 0
    )

    if mpv_check:
        rprint(":thumbs_up: [green] mpv is installed.")

        mpv_config = [
            inquirer.List(
                "interest",
                message="Install mpv configurations",
                choices=["No", "Yes"],
            ),
        ]
        mpv_config_answer = inquirer.prompt(mpv_config)

        if mpv_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run("mkdir -p ~/.config/mpv/", shell=True, stdout=DEVNULL)
            run(
                f"yes | cp -rf {dotfiles_path}/.config/mpv/* ~/.config/mpv/",
                shell=True,
                stdout=DEVNULL,
            )
            run(
                f"yes | cp -rf {dotfiles_path}/.xbindkeysrc ~/.xbindkeysrc",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] mpv is not installed.\n")

subprocess.run("clear", shell=True)

# ===== GTK-3.0 configuration
if os_answers["interest"] == "Arch":
    gtk_config = [
        inquirer.List(
            "interest",
            message="Install gtk configurations",
            choices=["No", "Yes"],
        )
    ]
    gtk_config_answer = inquirer.prompt(gtk_config)

    if gtk_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        subprocess.run("mkdir -p ~/.config/gtk-3.0/", shell=True, stdout=DEVNULL)
        subprocess.run(
            f"yes | cp -rf {dotfiles_path}/.config/gtk-3.0 $HOME/.config/",
            shell=True,
            stdout=DEVNULL,
        )
        subprocess.run(
            f"yes | cp -rf {dotfiles_path}/.config/mimeapps.list $HOME/.config/",
            shell=True,
            stdout=DEVNULL,
        )


subprocess.run("clear", shell=True)

# ===== I3 configuration
if os_answers["interest"] == "Arch":
    i3_check = (
        subprocess.run(
            "i3 --version", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        ).returncode
        == 0
    )

    if i3_check:
        rprint(":thumbs_up: [green] i3 is installed.")

        i3_config = [
            inquirer.List(
                "interest",
                message="Install i3 configurations",
                choices=["No", "Yes"],
            )
        ]
        i3_config_answer = inquirer.prompt(i3_config)

        if i3_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            subprocess.run(
                f"yes | cp -rf {dotfiles_path}/.config/i3 $HOME/.config/",
                shell=True,
                stdout=DEVNULL,
            )
            subprocess.run(
                f"yes | cp -rf {dotfiles_path}/.Xresources $HOME/",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] i3 is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Picom configuration
if os_answers["interest"] == "Arch":
    picom_check = (
        subprocess.run(
            "picom --version",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).returncode
        == 0
    )

    if picom_check:
        rprint(":thumbs_up: [green] picom is installed.")

        picom_config = [
            inquirer.List(
                "interest",
                message="Install picom configurations",
                choices=["No", "Yes"],
            )
        ]
        picom_config_answer = inquirer.prompt(picom_config)

        if picom_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run(
                f"yes | cp -rf {dotfiles_path}/.config/picom.conf $HOME/.config/",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] picom is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Rofi configuration
if os_answers["interest"] == "Arch":
    rofi_check = (
        subprocess.run(
            "rofi -v", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        ).returncode
        == 0
    )

    if rofi_check:
        rprint(":thumbs_up: [green] rofi is installed.")

        rofi_config = [
            inquirer.List(
                "interest",
                message="Install rofi configurations",
                choices=["No", "Yes"],
            )
        ]
        rofi_config_answer = inquirer.prompt(rofi_config)

        if rofi_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run(
                f"yes | cp -rf {dotfiles_path}/.config/rofi $HOME/.config/",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] rofi is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Polybar configuration
if os_answers["interest"] == "Arch":
    polybar_check = (
        subprocess.run(
            "polybar -v", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        ).returncode
        == 0
    )

    if polybar_check:
        rprint(":thumbs_up: [green] polybar is installed.")

        polybar_config = [
            inquirer.List(
                "interest",
                message="Install polybar configurations",
                choices=["No", "Yes"],
            )
        ]
        polybar_config_answer = inquirer.prompt(polybar_config)

        if polybar_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run(
                f"yes | cp -rf {dotfiles_path}/.config/polybar $HOME/.config/",
                shell=True,
                stdout=DEVNULL,
            )
            run(
                "cd ~/.config/polybar/scripts/ ; sudo chmod +xwr *.sh",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] polybar is not installed.\n")


subprocess.run("clear", shell=True)

# ===== Dunst configuration
if os_answers["interest"] == "Arch":
    dunst_check = (
        subprocess.run(
            "dunst -v", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        ).returncode
        == 0
    )

    if dunst_check:
        rprint(":thumbs_up: [green] dunst is installed.")

        dunst_config = [
            inquirer.List(
                "interest",
                message="Install dunst configurations",
                choices=["No", "Yes"],
            )
        ]
        dunst_config_answer = inquirer.prompt(dunst_config)

        if dunst_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run(
                f"yes | cp -rf {dotfiles_path}/.config/dunst $HOME/.config/",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] dunst is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Scrot configuration
if os_answers["interest"] == "Arch":
    scrot_check = (
        subprocess.run(
            "scrot -v", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        ).returncode
        == 0
    )

    if scrot_check:
        rprint(":thumbs_up: [green] scrot is installed.")

        scrot_config = [
            inquirer.List(
                "interest",
                message="Install scrot configurations",
                choices=["No", "Yes"],
            )
        ]
        scrot_config_answer = inquirer.prompt(scrot_config)

        if scrot_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run("mkdir -p $HOME/.screenshots", shell=True, stdout=DEVNULL)
    else:
        rprint("[red italic] scrot is not installed.\n")


subprocess.run("clear", shell=True)

# ===== Imwheel configuration
if os_answers["interest"] == "Arch":
    imwheel_check = (
        subprocess.run(
            "imwheel -v", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        ).returncode
        == 0
    )

    if imwheel_check:
        rprint(":thumbs_up: [green] imwheel is installed.")

        imwheel_config = [
            inquirer.List(
                "interest",
                message="Install imwheel configurations",
                choices=["No", "Yes"],
            )
        ]
        imwheel_config_answer = inquirer.prompt(imwheel_config)

        if imwheel_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run(
                f"yes | cp -rf {dotfiles_path}/.imwheelrc  $HOME/",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] imwheel is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Conky configuration
if os_answers["interest"] == "Arch":
    conky_check = (
        subprocess.run(
            "conky -v", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        ).returncode
        == 0
    )

    if conky_check:
        rprint(":thumbs_up: [green] conky is installed.")

        conky_config = [
            inquirer.List(
                "interest",
                message="Install conky configurations",
                choices=["No", "Yes"],
            )
        ]
        conky_config_answer = inquirer.prompt(conky_config)

        if conky_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run(
                f"yes | cp -rf {dotfiles_path}/.config/conky $HOME/.config/",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] conky is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Docker Configuration
if os_answers["interest"] == "Arch":
    docker_check = (
        subprocess.run(
            "sudo docker --version",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).returncode
        == 0
    )
    if docker_check:
        rprint(":thumbs_up: [green] Docker is installed.")
        docker_config = [
            inquirer.List(
                "interest",
                message="Configure Docker to run commands without sudo permission",
                choices=["No", "Yes"],
            )
        ]
        docker_config_answer = inquirer.prompt(docker_config)

        if docker_config_answer["interest"] == "Yes":
            subprocess.run("clear", shell=True)
            run(
                "sudo groupadd docker && sudo usermod -aG docker $(whoami) && newgrp docker",
                shell=True,
                stdout=DEVNULL,
            )
    else:
        rprint("[red italic] Docker is not installed.\n")


subprocess.run("clear", shell=True)

# ===== Pacman configuration
if os_answers["interest"] == "Arch":
    pacman_config = [
        inquirer.List(
            "interest",
            message="Install pacman configurations",
            choices=["No", "Yes"],
        )
    ]
    pacman_config_answer = inquirer.prompt(pacman_config)

    if pacman_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        run(
            "sudo sed -i -e 's/^#Color/Color/g' /etc/pacman.conf",
            shell=True,
            stdout=DEVNULL,
        )
        run(
            "sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads=5/g' /etc/pacman.conf",
            shell=True,
            stdout=DEVNULL,
        )


subprocess.run("clear", shell=True)

# ===== Jupyter configuration
jupyter_check = (
    subprocess.run(
        "jupyter notebook --version",
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).returncode
    == 0
)
if jupyter_check:
    rprint(":thumbs_up: [green] jupyter notebook is installed.")
    jupyter_config = [
        inquirer.List(
            "interest",
            message="Install jupyter notebook configuration",
            choices=["No", "Yes"],
        )
    ]
    jupyter_config_answer = inquirer.prompt(jupyter_config)

    if jupyter_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        run("mkdir -p ~/.jupyter/custom/", shell=True, stdout=DEVNULL)
        run(
            f"yes | sudo cp -rf {dotfiles_path}/.jupyter/custom/* ~/.jupyter/custom/",
            shell=True,
            stdout=DEVNULL,
        )
else:
    rprint("[red italic] jupyter is not installed.\n")

subprocess.run("clear", shell=True)

# ===== Appearance
# Apple_cursor
if os_answers["interest"] == "Arch":
    applecursor_config = [
        inquirer.List("interest", message="Install apple cursor", choices=["No", "Yes"])
    ]
    applecursor_config_answer = inquirer.prompt(applecursor_config)
    if applecursor_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        subprocess.run("mkdir -p ~/.icons; cd ~/.icons", shell=True, stdout=DEVNULL)
        subprocess.run(
            "wget https://github.com/ful1e5/apple_cursor/releases/latest/download/macOSMonterey.tar.gz",
            shell=True,
            stdout=DEVNULL,
        )
        subprocess.run(
            "tar xvf ~/.icons/macOSMonterey.tar.gz", shell=True, stdout=DEVNULL
        )
        subprocess.run("rm ~/.icons/macOSMonterey.tar.gz", shell=True, stdout=DEVNULL)
        subprocess.run("mkdir -p ~/.config/gtk-3.0", shell=True, stdout=DEVNULL)
        subprocess.run(
            f"yes | sudo cp -rf {dotfiles_path}/.config/gtk-3.0/* ~/.config/gtk-3.0/",
            shell=True,
            stdout=DEVNULL,
        )
        print("\n")


subprocess.run("clear", shell=True)

# # ===== Hibernate
# if os_answers["interest"] == "Arch":
#     hibernate_q = [
#         inquirer.List(
#             "hibernate",
#             message="Do you have any partion swap for enabling hibernate",
#             choices=["No", "Yes"],
#         )
#     ]
#     hibernate_answers = inquirer.prompt(hibernate_q)
#     if hibernate_answers["hibernate"] == "Yes":
#         subprocess.run("clear", shell=True)
#         subprocess.run(
#             "sudo blkid | grep 'swap' | grep -o '[[:space:]]UUID=\"[a-zA-Z0-9\-]*\"' | grep -o '[a-zA-Z0-9\-]*' | tail -n1 | xargs echo | xargs -I {} sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ resume=UUID={}\"/' /etc/default/grub",
#             shell=True,
#             stdout=DEVNULL,
#         )
#         subprocess.run(
#             "sudo sed -i '/^HOOKS=/ s/)$/ resume)/' /etc/mkinitcpio.conf",
#             shell=True,
#             stdout=DEVNULL,
#         )
#         subprocess.run("sudo grub-mkconfig -o /boot/grub/grub.cfg", shell=True)
#         subprocess.run("sudo mkinitcpio -P", shell=True)
#         print("\n")
#
#
# subprocess.run("clear", shell=True)

# ===== WSLU
if os_answers["interest"] == "WSL":
    wslu_config = [
        inquirer.List(
            "interest", message="Do you want to use wslu", choices=["No", "Yes"]
        )
    ]
    wslu_config_answer = inquirer.prompt(wslu_config)

    if wslu_config_answer["interest"] == "Yes":
        subprocess.run("clear", shell=True)
        os.system("wget https://pkg.wslutiliti.es/public.key")
        os.system("sudo pacman-key --add public.key")
        os.system("sudo pacman-key --lsign-key A2861ABFD897DD37")
        os.system(
            "sudo sh -c 'echo -e \"\n[wslutilities]\nServer = https://pkg.wslutiliti.es/arch/\" >> /etc/pacman.conf'"
        )
        os.system("sudo pacman -Sy --noconfirm && sudo pacman -S wslu --noconfirm")


# After In Arch:
# sptlrx with spotify --> [https://github.com/raitonoberu/sptlrx] -- sptlrx -c <cookie> -- check ~/.config/sptlrx/config.yaml -- use spotify app
# xappearance
# xfce4 power manager
# Nvidia --> add to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub : "omodeset i915.modeset=0"
