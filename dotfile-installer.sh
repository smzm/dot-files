#!/usr/bin/env bash
#
# Arch / Arch-WSL Dotfiles Installer
#
# Requirements:
#   - bash
#   - pacman
#
# Everything else is installed by this script.
#
# Usage:
#   ./install.sh
#
# ================================================================
# Package database format
#
# SECTION | NAME | MANAGER | DESCRIPTION | CONFIG | COMMAND
#
# SECTION:
#   1 = Hardware & Drivers
#   2 = Hyprland / Wayland
#   3 = Desktop Essentials
#   4 = Waybar
#   5 = Fonts
#   6 = Shell
#   7 = Terminal & CLI
#   8 = Development
#   9 = Applications
#
# MANAGER:
#   pacman
#   aur
#   npm
#   cargo
#   script
#   None
#
# CONFIG:
#   config:SOURCE=>DESTINATION
#
# COMMAND:
#   command:SHELL COMMAND
#
# ================================================================
# Safety
# ================================================================

set -u
set -o pipefail

# Do NOT use `set -e`.
# Package installation failures are intentionally handled by us.


# ================================================================
# Paths
# ================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

CONFIG_DIR="$HOME_DIR/.config"


# ================================================================
# Colors
# ================================================================

if [[ -t 1 ]]; then
    RESET='\033[0m'
    BOLD='\033[1m'
    DIM='\033[2m'

    RED='\033[31m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
    BLUE='\033[34m'
    MAGENTA='\033[35m'
    CYAN='\033[36m'
    WHITE='\033[37m'
else
    RESET=''
    BOLD=''
    DIM=''

    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    WHITE=''
fi


# ================================================================
# Sections
# ================================================================

SECTION_NAMES=(
    "Hardware & Drivers"
    "Hyprland / Wayland"
    "Desktop Essentials"
    "Waybar"
    "Fonts"
    "Shell"
    "Terminal & CLI"
    "Development"
    "Applications"
)


# ================================================================
# Package database
#
# SECTION | NAME | MANAGER | DESCRIPTION | CONFIG | COMMAND
# ================================================================

PACKAGES=(

    # ═════════════════════════════════════════════════════════════
    # Hardware & Drivers
    # Section 1
    # ═════════════════════════════════════════════════════════════

    "1|nvidia-open|pacman|Open NVIDIA kernel module||"
    "1|nvidia-utils|pacman|NVIDIA userspace utilities and libraries||"
    "1|vulkan-tools|pacman|Vulkan diagnostic and information utilities||"

    "1|pipewire|pacman|Modern Linux audio and video framework||command:systemctl --user enable --now pipewire.service && systemctl --user enable --now pipewire-pulse.service"
    "1|pipewire-pulse|pacman|PulseAudio compatibility layer using PipeWire||"
    "1|pipewire-audio|pacman|PipeWire audio support||"
    "1|pipewire-alsa|pacman|ALSA support through PipeWire||"
    "1|pipewire-jack|pacman|JACK compatibility through PipeWire||"

    "1|wireplumber|pacman|PipeWire session and policy manager||command:systemctl --user enable --now wireplumber.service"

    "1|pavucontrol|pacman|GTK volume and audio device controller||"

    "1|networkmanager|pacman|Network connection manager||"
    "1|network-manager-applet|pacman|NetworkManager graphical tray applet||"
    "1|networkmanager-openvpn|pacman|OpenVPN support for NetworkManager||"

    "1|bluez|pacman|Linux Bluetooth protocol stack||"
    "1|bluez-utils|pacman|Bluetooth command-line utilities||"
    "1|blueman|pacman|GTK Bluetooth device manager||"

    "1|mtpfs|pacman|FUSE filesystem for mounting MTP devices such as Android phones||"
    "1|gvfs-mtp|pacman|GVFS support for MTP devices such as Android phones||"
    "1|gvfs-gphoto2|pacman|GVFS support for cameras and PTP devices||"


    # ═════════════════════════════════════════════════════════════
    # Hyprland / Wayland
    # Section 2
    # ═════════════════════════════════════════════════════════════

    "2|ly|pacman|Lightweight terminal display manager||"

    "2|hyprland|pacman|Dynamic tiling Wayland compositor|config:.config/hypr=>~/.config/hypr|"

    "2|xdg-desktop-portal|pacman|Desktop integration portal framework||"
    "2|xdg-desktop-portal-hyprland|pacman|XDG desktop portal backend for Hyprland||"
    "2|xdg-desktop-portal-gtk|pacman|GTK XDG desktop portal backend||"

    "2|hyprpicker|pacman|Color picker for Hyprland and Wayland||"
    "2|hyprpaper|pacman|Fast Wayland wallpaper utility||"
    "2|waypaper|aur|GUI wallpaper manager for Wayland and Xorg Linux systems|| "
    "2|hyprpolkitagent|pacman|Polkit authentication agent for Hyprland||"
    "2|hypridle|pacman|Idle management daemon for Hyprland||"
    "2|wlogout|aur|Wayland logout and power menu||"

    "2|qt5-wayland|pacman|Wayland platform plugin for Qt5||"
    "2|qt6-wayland|pacman|Wayland platform plugin for Qt6||"
    "2|qt6ct|pacman|Qt6 configuration utility||"


    # ═════════════════════════════════════════════════════════════
    # Desktop Essentials
    # Section 3
    # ═════════════════════════════════════════════════════════════

    "3|rofi|pacman|Application launcher|config:.config/rofi=>~/.config/rofi|"
    "3|dunst|pacman|Lightweight desktop notification daemon|config:.config/dunst=>~/.config/dunst;.config/systemd/user/dunst.service=>~/.config/systemd/user/dunst.service|command:systemctl --user daemon-reload && systemctl --user enable --now dunst.service"

    "3|nwg-look|pacman|GTK theme configuration utility for Wayland||"
    "3|gnome-themes-extra|pacman|Additional GNOME and GTK themes||"

    "3|wl-clipboard|pacman|Wayland clipboard command-line utilities||"
    "3|clipse|aur|TUI clipboard manager for Wayland|config:.config/systemd/user/clipse.service=>~/.config/systemd/user/clipse.service|command:systemctl --user daemon-reload && systemctl --user enable --now clipse.service"

    "3|grim|pacman|Screenshot utility for Wayland||"
    "3|slurp|pacman|Interactive Wayland region selector||"
    "3|swappy|pacman|Wayland screenshot annotation tool||"

    "3|udiskie|pacman|Removable-disk automounter|config:.config/systemd/user/udiskie.service=>~/.config/systemd/user/udiskie.service|command:systemctl --user daemon-reload && systemctl --user enable --now udiskie.service"
    "3|udisks2|pacman|Disk management service||"

    "3|imv|pacman|Simple image viewer with Wayland support||"

    "3|mpv|pacman|Powerful command-line media player|config:.config/mpv=>~/.config/mpv|"
    "3|mpv-mpris|pacman|MPRIS support for MPV||"

    "3|ffmpeg|pacman|Audio and video processing framework||"
    "3|ffmpegthumbnailer|pacman|Video thumbnail generator||"

    "3|poppler|pacman|PDF rendering and processing tools||"

    "3|evince|pacman|Document viewer (PDF, PostScript, XPS, djvu, dvi, tiff, cbr, cbz, cb7, cbt)||"
    "3|zathura|pacman|Minimalist document viewer|config:.config/zathura=>~/.config/zathura|"
    "3|zathura-pdf-mupdf|pacman|PDF backend for Zathura||"

    "3|gammastep|pacman|Screen color temperature and brightness adjustment||"

    "3|gnome-keyring|pacman|Stores passwords and encryption keys||"
    "3|libsecret|pacman|Library for storing and retrieving passwords and other secrets||"


    # ═════════════════════════════════════════════════════════════
    # Waybar
    # Section 4
    # ═════════════════════════════════════════════════════════════

    "4|waybar|pacman|Highly customizable Wayland status bar|config:.config/waybar=>~/.config/waybar|"

    "4|inotify-tools|pacman|Filesystem event monitoring utilities||"
    "4|python-setuptools|pacman|Python package build and installation utilities||"
    "4|zscroll|aur|Scrolling text utility for status bars||"
    "4|playerctl|pacman|Command-line MPRIS media player controller|config:.config/systemd/user/playerctl.service=>~/.config/systemd/user/playerctl.service|command:systemctl --user daemon-reload && systemctl --user enable --now playerctl.service"
    "4|brightnessctl|pacman|Backlight and brightness control utility||"
    "4|geoip|pacman|GeoIP database and lookup utilities||"

    "4|curl|pacman|Command-line HTTP and data transfer utility||"
    "4|awk|pacman|Text processing language and utility||"
    "4|coreutils|pacman|Core GNU command-line utilities||"

    "4|waybar-lyric|aur|Waybar lyrics module||"

    "4|jq|pacman|Command-line JSON processor||"
    "4|bc|pacman|Arbitrary precision calculator||"
    "4|htop|pacman|Interactive process viewer||"


    # ═════════════════════════════════════════════════════════════
    # Fonts
    # Section 5
    # ═════════════════════════════════════════════════════════════

    "5|noto-fonts|pacman|Noto font family||"
    "5|noto-fonts-emoji|pacman|Noto emoji font||"
    "5|noto-fonts-cjk|pacman|Noto fonts for Chinese Japanese and Korean text||"

    "5|ttf-firacode-nerd|pacman|FiraCode Nerd Font with programming symbols||"
    "5|ttf-jetbrains-mono-nerd|pacman|JetBrains Mono Nerd Font||"

    "5|otf-font-awesome|pacman|Font Awesome WOFF2 icon font||"
    "5|inter-font|pacman|Inter UI font||"
    "5|fontconfig|None|Font aliases and settings|config:.config/fontconfig=>~/.config/fontconfig|command:fc-cache -f"


    # ═════════════════════════════════════════════════════════════
    # Shell
    # Section 6
    # ═════════════════════════════════════════════════════════════

    "6|zsh|pacman|ZSH shell|config:.zshrc=>~/.zshrc|command:chsh -s /usr/bin/zsh"

    "6|zsh-theme-powerlevel10k|aur|Powerlevel10k theme for Zsh|config:.p10k.zsh=>~/.p10k.zsh|"

    "6|oh-my-zsh|None|Zsh configuration framework||command:if [[ ! -d \"\$HOME/.oh-my-zsh\" ]]; then RUNZSH=no CHSH=no sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"; fi"

    "6|zsh-autosuggestions|pacman|Fish-like autosuggestions for Zsh||"
    "6|zsh-syntax-highlighting|pacman|Syntax highlighting for Zsh||"

    "6|tmux|pacman|Terminal multiplexer|config:.config/tmux=>~/.config/tmux|command:if [[ ! -d \"$HOME/.config/tmux/plugins/tpm\" ]]; then git clone https://github.com/tmux-plugins/tpm \"$HOME/.config/tmux/plugins/tpm\"; fi"


    # ═════════════════════════════════════════════════════════════
    # Terminal & CLI
    # Section 7
    # ═════════════════════════════════════════════════════════════

    "7|yazi|aur|Terminal file manager|config:.config/yazi=>~/.config/yazi|command:cd \"$HOME/.config/yazi\" && ya pkg add yazi-rs/plugins:full-border"

    "7|mediainfo|pacman|Media metadata inspector||"
    "7|imagemagick|pacman|Image manipulation toolkit||"
    "7|ripgrep|pacman|Fast recursive search tool||"
    "7|fd|pacman|Fast find alternative||"
    "7|fzf|pacman|Command-line fuzzy finder||"
    "7|zoxide|pacman|Smarter cd command||"
    "7|tldr|pacman|Simplified command-line documentation||"
    "7|aria2|pacman|Multi-protocol download utility||"

    "7|tree|pacman|Directory tree viewer||"
    "7|lsd|pacman|Modern ls replacement||"
    "7|eza|pacman|Modern replacement for ls||"

    "7|unrar|pacman|RAR archive extraction utility||"
    "7|unzip|pacman|ZIP archive extraction utility||"
    "7|tar|pacman|Archive utility||"
    "7|p7zip|pacman|7-Zip archive support||"

    "7|ntfsprogs|pacman|NTFS filesystem utilities||"

    "7|yt-dlp|pacman|Media downloader||"
    "7|lf|pacman|Terminal file manager||"

    "7|lazygit|pacman|Terminal UI for Git|config:.config/lazygit=>~/.config/lazygit|"
    "7|lazydocker|pacman|Terminal UI for Docker||"

    "7|github-cli|pacman|GitHub command-line interface||command:gh auth login"


    # ═════════════════════════════════════════════════════════════
    # Development
    # Section 8
    # ═════════════════════════════════════════════════════════════

    "8|git|pacman|Distributed version control system||"
    "8|clang|pacman|LLVM C/C++ compiler||"
    "8|llvm|pacman|LLVM compiler infrastructure||"

    "8|neovim|pacman|Extensible terminal text editor|config:.config/nvim=>~/.config/nvim|command:nvim --headless \"+Lazy! sync\" +qa"

    "8|python|pacman|Python programming language||"
    "8|python-pip|pacman|Python package installer||"
    "8|uv|pacman|Extremely fast Python package installer||"

    "8|python-pynvim|pacman|Python client for Neovim||"
    "8|python-ipykernel|pacman|Jupyter Python kernel||"
    "8|python-pillow|pacman|Python imaging library||"
    "8|python-cairosvg|pacman|SVG renderer for Python||"
    "8|python-pyperclip|pacman|Python clipboard library||"

    "8|pyright|aur|Python type checker and language server||"

    "8|nodejs|pacman|JavaScript runtime||"
    "8|npm|pacman|Node.js package manager||command:mkdir -p \"$HOME/.npm\" && npm config set prefix \"$HOME/.npm\""

    "8|bun|pacman|JavaScript runtime and package manager||"
    "8|yarn|pacman|JavaScript package manager||"

    "8|rustup|pacman|Rust toolchain installer||command:rustup install stable"
    "8|rust-analyzer|pacman|Rust language server||"
    "8|lldb|pacman|LLVM debugger||"

    "8|tree-sitter-cli|cargo|Tree-sitter command-line interface||"

    "8|docker|pacman|Container engine||command:sudo groupadd -f docker && sudo usermod -aG docker \"$USER\""
    "8|docker-compose|pacman|Docker Compose integration||"
    "8|docker-buildx|pacman|Docker Buildx plugin||"

    "8|typescript|pacman|TypeScript language||"

    "8|typescript-language-server|aur|TypeScript language server||"
    "8|vim-language-server|aur|Vim language server||"

    "8|vscode-langservers-extracted|npm|HTML CSS and JSON language servers||"
    "8|emmet-ls|npm|Emmet language server||"
    "8|bash-language-server|npm|Bash language server||"
    "8|yaml-language-server|npm|YAML language server||"
    "8|neovim|npm|Neovim Node.js provider||"
    "8|biome|npm|JavaScript and TypeScript formatter and linter||"
    "8|prettier|npm|Code formatter||"

    "8|opencode|pacman|AI-powered coding agent for the terminal|config:.config/opencode=>~/.config/opencode|"


    # ═════════════════════════════════════════════════════════════
    # Applications
    # Section 9
    # ═════════════════════════════════════════════════════════════

    "9|kitty|pacman|GPU-accelerated terminal emulator|config:.config/kitty=>~/.config/kitty|"

    "9|nautilus|pacman|GNOME file manager||"
    "9|strata|aur|A fast, keyboard-first file manager for Linux||"
    "9|file-roller|pacman|Archive manager||"

    "9|zen-browser-bin|aur|Privacy-focused Firefox-based web browser||"

    "9|telegram-desktop|pacman|Telegram desktop client||"
    "9|gnome-calculator|pacman|GNOME calculator application||"
    "9|zed|pacman|High-performance modern code editor|config:.config/zed=>~/.config/zed|"
    "9|visual-studio-code-bin|aur|Microsoft Visual Studio Code binary package||"
    "9|obsidian|pacman|Markdown knowledge-management application||"

    "9|ocrdesktop|pacman|Desktop OCR utility||"
    "9|tesseract-data-eng|pacman|English OCR language data||"

    "9|windscribe|None|windscribe VPN|config:.config/systemd/user/windscribe.service=>~/.config/systemd/user/windscribe.service|command:systemctl --user daemon-reload && systemctl --user enable --now windscribe.service"

    "9|mimeapps.list|None|MIME type associations|config:.config/mimeapps.list=>~/.config/mimeapps.list"

    "9|spotify|aur|Spotify client|config:applications/spotify.desktop=>~/.local/share/applications/spotify.desktop|command:update-desktop-database ~/.local/share/applications"

)


# ================================================================
# Global result arrays
# ================================================================

INSTALLED=()
SKIPPED=()
FAILED=()

CURRENT_SECTION_INSTALLED=()
CURRENT_SECTION_SKIPPED=()
CURRENT_SECTION_FAILED=()

SELECTED_PACKAGES=()


# ================================================================
# Utility functions
# ================================================================

print_header() {

    local title="$1"

    echo
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}${BOLD}  $title${RESET}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
}


print_section_header() {

    local number="$1"
    local name="$2"

    echo
    echo -e "${MAGENTA}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    printf "${MAGENTA}${BOLD}║  Section %s: %-45s ║${RESET}\n" "$number" "$name"
    echo -e "${MAGENTA}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo
}


info() {
    echo -e "${BLUE}==>${RESET} $*"
}


success() {
    echo -e "${GREEN}✓${RESET} $*"
}


warning() {
    echo -e "${YELLOW}!${RESET} $*"
}


error() {
    echo -e "${RED}✗${RESET} $*"
}


ask_yes_no() {

    local question="$1"
    local answer

    read -r -p "$question [Y/n] " answer

    answer="${answer:-Y}"

    [[ "$answer" =~ ^[Yy]$ ]]
}


expand_path() {

    local path="$1"

    path="${path/#\~/$HOME}"

    echo "$path"
}


# ================================================================
# Interactive command execution
#
# Installations keep `--noconfirm`, so the installer never asks
# whether a package should be installed.
#
# Commands may still have to ask something in the middle of an
# installation (sudo password, PGP key import, `gh auth login`,
# `chsh`, ...).
#
# Those prompts must stay answerable, so installation commands are
# attached to the terminal instead of inheriting whatever stdin the
# installer itself was started with.
# ================================================================

if [[ -e /dev/tty ]] && (: < /dev/tty) 2>/dev/null; then
    TTY_INPUT="/dev/tty"
else
    TTY_INPUT=""
fi


run_interactive() {

    if [[ -n "$TTY_INPUT" ]]; then
        "$@" < "$TTY_INPUT"
    else
        "$@"
    fi
}


# ================================================================
# Check Arch
# ================================================================

check_arch() {

    if [[ ! -f /etc/arch-release ]]; then
        error "This installer is designed for Arch Linux / Arch WSL."
        exit 1
    fi
}


# ================================================================
# Sudo
# ================================================================

prepare_sudo() {

    if [[ "$EUID" -eq 0 ]]; then
        error "Do not run this installer as root."
        exit 1
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        error "sudo is required."
        error "Install sudo first."
        exit 1
    fi

    info "Checking sudo access..."

    sudo -v
}


# ================================================================
# Refresh sudo timestamp in background
# ================================================================

keep_sudo_alive() {

    (
        while true; do
            sudo -n true 2>/dev/null
            sleep 50
        done
    ) &

    SUDO_KEEPALIVE_PID=$!
}


cleanup() {

    if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
}


trap cleanup EXIT


# ================================================================
# Package database helpers
# ================================================================

package_installed_pacman() {

    pacman -Q "$1" >/dev/null 2>&1
}


package_installed_aur() {

    pacman -Q "$1" >/dev/null 2>&1
}


package_installed_npm() {

    if ! command -v npm >/dev/null 2>&1; then
        return 1
    fi

    npm list -g --depth=0 "$1" >/dev/null 2>&1
}


package_installed_cargo() {

    if ! command -v cargo >/dev/null 2>&1; then
        return 1
    fi

    cargo install --list 2>/dev/null |
        grep -qE "^$1 v"
}


package_installed() {

    local name="$1"
    local manager="$2"

    case "$manager" in

        pacman)
            package_installed_pacman "$name"
            ;;

        aur)
            package_installed_aur "$name"
            ;;

        npm)
            package_installed_npm "$name"
            ;;

        cargo)
            package_installed_cargo "$name"
            ;;

        *)
            return 1
            ;;
    esac
}


# ================================================================
# Yay
# ================================================================

ensure_yay() {

    if command -v yay >/dev/null 2>&1; then
        return 0
    fi

    print_header "Installing yay"

    info "yay is not installed."
    info "Installing base-devel..."

    if ! run_interactive sudo pacman -S --needed --noconfirm base-devel git; then
        error "Failed to install base-devel/git."
        return 1
    fi

    local tmp_dir

    tmp_dir="$(mktemp -d)"

    info "Cloning yay..."

    if ! run_interactive git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"; then
        error "Failed to clone yay."
        rm -rf "$tmp_dir"
        return 1
    fi

    info "Building and installing yay..."

    if ! (
        cd "$tmp_dir/yay" &&
        run_interactive makepkg -si --noconfirm
    ); then

        error "Failed to install yay."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"

    if command -v yay >/dev/null 2>&1; then
        success "yay installed successfully."
        return 0
    fi

    error "yay installation completed but yay was not found."
    return 1
}


# ================================================================
# Interactive retry
#
# `--noconfirm` answers every question with its default, and the
# default of a conflict question is "no":
#
#   :: A and B are in conflict (x). Remove B? [y/N]
#   error: unresolvable package conflicts detected
#
# The same happens when a transaction needs a provider to be
# picked. Those are decisions only the user can make, so instead
# of failing the package, the transaction is run once more without
# `--noconfirm` and the question is handed over to the user.
# ================================================================

needs_interactive_retry() {

    local name="$1"

    # Without a terminal there is nobody to answer anything.

    if [[ -z "$TTY_INPUT" ]]; then
        return 1
    fi

    echo
    warning "${BOLD}$name${RESET} could not be installed unattended."
    info "Retrying without --noconfirm so the questions can be answered."
    echo

    return 0
}


# ================================================================
# Install package
# ================================================================

install_package() {

    local name="$1"
    local manager="$2"

    case "$manager" in

        pacman)

            info "Installing ${BOLD}$name${RESET} with pacman..."

            if run_interactive sudo pacman -S --needed --noconfirm "$name"; then
                return 0
            fi

            needs_interactive_retry "$name" || return 1

            run_interactive sudo pacman -S --needed "$name"
            ;;


        aur)

            if ! command -v yay >/dev/null 2>&1; then
                ensure_yay || return 1
            fi

            info "Installing ${BOLD}$name${RESET} from AUR..."

            if run_interactive yay -S --needed --noconfirm "$name"; then
                return 0
            fi

            needs_interactive_retry "$name" || return 1

            # Only the packaging questions keep their default, the
            # conflict and provider questions are left to the user.

            run_interactive yay -S --needed \
                --answerdiff=None \
                --answerclean=None \
                --answeredit=None \
                "$name"
            ;;


        npm)

            if ! command -v npm >/dev/null 2>&1; then
                error "npm is not installed."
                return 1
            fi

            info "Installing global npm package ${BOLD}$name${RESET}..."

            mkdir -p "$HOME/.npm"

            npm config set prefix "$HOME/.npm" >/dev/null 2>&1 || true

            export PATH="$HOME/.npm/bin:$PATH"

            # npm defaults hide everything behind a spinner and wait
            # up to 5 minutes per request before retrying, which looks
            # like a frozen installer on a slow registry.
            #
            #   --loglevel=info      progress of every request, live
            #   --foreground-scripts install scripts stream their output
            #   --no-progress        no spinner hiding that output
            #   --no-audit           no extra registry round trip
            #   --no-fund            no extra registry round trip
            #   --no-update-notifier no background version check
            #   --fetch-*            fail in bounded time, not silently

            run_interactive npm install -g \
                --loglevel=info \
                --foreground-scripts \
                --no-progress \
                --no-audit \
                --no-fund \
                --no-update-notifier \
                --fetch-timeout=60000 \
                --fetch-retries=2 \
                --fetch-retry-mintimeout=5000 \
                --fetch-retry-maxtimeout=20000 \
                "$name"
            ;;


        cargo)

            if ! command -v cargo >/dev/null 2>&1; then
                error "cargo is not installed."
                return 1
            fi

            info "Installing ${BOLD}$name${RESET} with cargo..."

            run_interactive cargo install --locked "$name"
            ;;



        None)

            info "${BOLD}$name${RESET} does not require package installation."

            return 0
            ;;


        *)

            error "Unknown package manager: $manager"

            return 1
            ;;
    esac
}


# ================================================================
# Copy configuration
# ================================================================

copy_config() {

    local config="$1"

    [[ -z "$config" ]] && return 0

    config="${config#config:}"

    local operation
    local source
    local destination

    IFS=';' read -ra operations <<< "$config"

    for operation in "${operations[@]}"; do

        [[ -z "$operation" ]] && continue

        if [[ "$operation" != *"=>"* ]]; then

            error "Invalid config syntax:"
            error "  $operation"
            error "Expected:"
            error "  SOURCE=>DESTINATION"

            return 1
        fi

        source="${operation%%=>*}"
        destination="${operation#*=>}"

        if [[ -z "$source" || -z "$destination" ]]; then

            error "Invalid config operation:"
            error "  $operation"

            return 1
        fi

        source="$(expand_path "$source")"
        destination="$(expand_path "$destination")"

        if [[ "$source" != /* ]]; then
            source="$DOTFILES_DIR/$source"
        fi

        if [[ ! -e "$source" ]]; then

            error "Configuration source does not exist:"
            error "  $source"

            return 1
        fi

        info "Copying configuration:"
        echo -e "  ${DIM}$source${RESET}"
        echo -e "  ${GREEN}→${RESET} ${DIM}$destination${RESET}"

        if ! mkdir -p "$(dirname "$destination")"; then

            error "Failed to create destination directory:"
            error "  $(dirname "$destination")"

            return 1
        fi

        if [[ -d "$source" ]]; then

            if ! mkdir -p "$destination"; then

                error "Failed to create destination:"
                error "  $destination"

                return 1
            fi

            if ! cp -a "$source/." "$destination/"; then

                error "Failed to copy:"
                error "  $source"
                error "  → $destination"

                return 1
            fi

        else

            if ! cp -a "$source" "$destination"; then

                error "Failed to copy:"
                error "  $source"
                error "  → $destination"

                return 1
            fi
        fi

    done

    return 0
}


# ================================================================
# Run command
# ================================================================

run_command() {

    local command="$1"

    [[ -z "$command" ]] && return 0

    command="${command#command:}"

    info "Running post-install command..."

    echo -e "${DIM}$command${RESET}"
    echo

    run_interactive bash -c "$command"
}


# ================================================================
# Parse package entry
# ================================================================

parse_package() {

    local entry="$1"

    IFS='|' read -r \
        PKG_SECTION \
        PKG_NAME \
        PKG_MANAGER \
        PKG_DESCRIPTION \
        PKG_CONFIG \
        PKG_COMMAND \
        <<< "$entry"
}


# ================================================================
# Package identifier
# ================================================================

package_id() {

    local name="$1"
    local manager="$2"

    echo "${manager}:${name}"
}


# ================================================================
# Find package entry
# ================================================================

find_package_entry() {

    local wanted_name="$1"
    local wanted_manager="$2"

    local entry
    local name
    local manager

    for entry in "${PACKAGES[@]}"; do

        IFS='|' read -r _ name manager _ <<< "$entry"

        if [[ "$name" == "$wanted_name" && "$manager" == "$wanted_manager" ]]; then
            echo "$entry"
            return 0
        fi
    done

    return 1
}


# ================================================================
# Package selection menu
#
# Selection examples:
#
#   0       = install all
#   a       = install all
#   1       = install package 1
#   1 3 5   = install packages 1, 3 and 5
#   1-5     = install packages 1 through 5
#   1 3-5 8 = mixed selection
#   q       = go back
# ================================================================

select_section_packages() {

    local section_number="$1"
    local section_name="${SECTION_NAMES[$((section_number - 1))]}"

    local section_entries=()

    local entry

    # ------------------------------------------------------------
    # Collect packages for this section.
    # ------------------------------------------------------------

    for entry in "${PACKAGES[@]}"; do

        parse_package "$entry"

        if [[ "$PKG_SECTION" != "$section_number" ]]; then
            continue
        fi

        section_entries+=("$entry")
    done


    # ------------------------------------------------------------
    # Nothing available.
    # ------------------------------------------------------------

    if ((${#section_entries[@]} == 0)); then

        warning "No packages are available for this section."

        echo
        read -r -p "Press ENTER to continue..."

        return 1
    fi


    while true; do

        clear

        print_section_header "$section_number" "$section_name"

        echo -e "${BOLD}Available packages:${RESET}"
        echo


        # --------------------------------------------------------
        # Display packages.
        # --------------------------------------------------------

        local i=1

        for entry in "${section_entries[@]}"; do

            parse_package "$entry"

            local status=""

            if [[ "$PKG_MANAGER" == "None" ]]; then

                status="${DIM}[configuration]${RESET}"

            elif package_installed "$PKG_NAME" "$PKG_MANAGER"; then

                status="${GREEN}[installed]${RESET}"
            fi


            printf "  ${CYAN}%2d)${RESET} %-30s ${DIM}%s${RESET} %b\n" \
                "$i" \
                "$PKG_NAME" \
                "$PKG_DESCRIPTION" \
                "$status"

            ((i++))
        done


        echo
        echo -e "${BOLD}Selection:${RESET}"
        echo
        echo -e "  ${CYAN}0${RESET}       Install ALL packages"
        echo -e "  ${CYAN}1 3 5${RESET}   Install selected packages"
        echo -e "  ${CYAN}1-5${RESET}     Install a range"
        echo -e "  ${CYAN}a${RESET}       Install ALL packages"
        echo -e "  ${CYAN}q${RESET}       Go back"
        echo


        local selection

        read -r -p "Select packages: " selection


        # --------------------------------------------------------
        # Go back.
        # --------------------------------------------------------

        if [[ "$selection" =~ ^[Qq]$ ]]; then
            return 1
        fi


        # --------------------------------------------------------
        # Install all.
        # --------------------------------------------------------

        if [[ "$selection" == "0" || "$selection" =~ ^[Aa]$ ]]; then

            SELECTED_PACKAGES=("${section_entries[@]}")

            return 0
        fi


        # --------------------------------------------------------
        # Normalize commas.
        #
        # 1,3,5 -> 1 3 5
        # --------------------------------------------------------

        selection="${selection//,/ }"


        # --------------------------------------------------------
        # Split input into tokens.
        # --------------------------------------------------------

        local tokens=()

        read -ra tokens <<< "$selection"


        local selected_indexes=()

        local token
        local number
        local start
        local end
        local n

        local valid=1


        # --------------------------------------------------------
        # Parse each token.
        # --------------------------------------------------------

        for token in "${tokens[@]}"; do

            # ----------------------------------------------------
            # Single number.
            # ----------------------------------------------------

            if [[ "$token" =~ ^[0-9]+$ ]]; then

                number="$token"

                if ((number < 1 || number > ${#section_entries[@]})); then

                    warning "Invalid package number: $number"

                    valid=0

                    break
                fi

                selected_indexes+=("$number")

                continue
            fi


            # ----------------------------------------------------
            # Range.
            # ----------------------------------------------------

            if [[ "$token" =~ ^([0-9]+)-([0-9]+)$ ]]; then

                start="${BASH_REMATCH[1]}"
                end="${BASH_REMATCH[2]}"


                if ((start < 1 || end > ${#section_entries[@]} || start > end)); then

                    warning "Invalid package range: $token"

                    valid=0

                    break
                fi


                for ((n = start; n <= end; n++)); do
                    selected_indexes+=("$n")
                done

                continue
            fi


            # ----------------------------------------------------
            # Invalid token.
            # ----------------------------------------------------

            warning "Invalid selection: $token"

            valid=0

            break
        done


        # --------------------------------------------------------
        # Invalid selection.
        # --------------------------------------------------------

        if ((valid == 0 || ${#selected_indexes[@]} == 0)); then

            echo
            read -r -p "Press ENTER to try again..."

            continue
        fi


        # --------------------------------------------------------
        # Remove duplicate indexes.
        # --------------------------------------------------------

        local unique_indexes=()
        local seen=" "
        local index

        for index in "${selected_indexes[@]}"; do

            if [[ "$seen" != *" $index "* ]]; then

                unique_indexes+=("$index")

                seen+=" $index "
            fi
        done


        # --------------------------------------------------------
        # Build selected package entries.
        # --------------------------------------------------------

        SELECTED_PACKAGES=()

        for index in "${unique_indexes[@]}"; do

            SELECTED_PACKAGES+=(
                "${section_entries[$((index - 1))]}"
            )
        done


        return 0
    done
}


# ================================================================
# Process one package
# ================================================================

process_package() {

    local entry="$1"

    parse_package "$entry"

    echo
    echo -e "${BOLD}${CYAN}[$PKG_NAME]${RESET}"
    echo -e "  ${DIM}$PKG_DESCRIPTION${RESET}"


    # ------------------------------------------------------------
    # No package manager
    # ------------------------------------------------------------

    if [[ "$PKG_MANAGER" == "None" ]]; then

        if [[ -n "$PKG_CONFIG" ]]; then

            if ! copy_config "$PKG_CONFIG"; then

                CURRENT_SECTION_FAILED+=(
                    "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
                )

                FAILED+=(
                    "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
                )

                return 1
            fi
        fi

        if [[ -n "$PKG_COMMAND" ]]; then

            if ! run_command "$PKG_COMMAND"; then

                CURRENT_SECTION_FAILED+=(
                    "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
                )

                FAILED+=(
                    "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
                )

                return 1
            fi
        fi

        CURRENT_SECTION_INSTALLED+=("$PKG_NAME")
        INSTALLED+=("$PKG_NAME")

        success "$PKG_NAME : configured"

        return 0
    fi


    # ------------------------------------------------------------
    # Already installed
    # ------------------------------------------------------------

    if package_installed "$PKG_NAME" "$PKG_MANAGER"; then

        CURRENT_SECTION_SKIPPED+=("$PKG_NAME")
        SKIPPED+=("$PKG_NAME")

        success "$PKG_NAME : already installed"


        # Configuration is still synchronized.

        if [[ -n "$PKG_CONFIG" ]]; then

            if ! copy_config "$PKG_CONFIG"; then

                CURRENT_SECTION_FAILED+=(
                    "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
                )

                FAILED+=(
                    "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
                )

                return 1
            fi
        fi


        # Commands intentionally run for already-installed packages.

        if [[ -n "$PKG_COMMAND" ]]; then

            if ! run_command "$PKG_COMMAND"; then

                CURRENT_SECTION_FAILED+=(
                    "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
                )

                FAILED+=(
                    "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
                )

                return 1
            fi
        fi

        return 0
    fi


    # ------------------------------------------------------------
    # Install
    # ------------------------------------------------------------

    if ! install_package "$PKG_NAME" "$PKG_MANAGER"; then

        error "$PKG_NAME : installation failed"

        CURRENT_SECTION_FAILED+=(
            "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
        )

        FAILED+=(
            "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
        )

        return 1
    fi


    # ------------------------------------------------------------
    # Configuration
    # ------------------------------------------------------------

    if [[ -n "$PKG_CONFIG" ]]; then

        if ! copy_config "$PKG_CONFIG"; then

            error "$PKG_NAME : configuration failed"

            CURRENT_SECTION_FAILED+=(
                "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
            )

            FAILED+=(
                "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
            )

            return 1
        fi
    fi


    # ------------------------------------------------------------
    # Post-install command
    # ------------------------------------------------------------

    if [[ -n "$PKG_COMMAND" ]]; then

        if ! run_command "$PKG_COMMAND"; then

            error "$PKG_NAME : post-install command failed"

            CURRENT_SECTION_FAILED+=(
                "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
            )

            FAILED+=(
                "$(package_id "$PKG_NAME" "$PKG_MANAGER")"
            )

            return 1
        fi
    fi


    CURRENT_SECTION_INSTALLED+=("$PKG_NAME")
    INSTALLED+=("$PKG_NAME")

    success "$PKG_NAME : installed"

    return 0
}


# ================================================================
# Reset current section state
# ================================================================

reset_section_results() {

    CURRENT_SECTION_INSTALLED=()
    CURRENT_SECTION_SKIPPED=()
    CURRENT_SECTION_FAILED=()
}


# ================================================================
# Retry failed packages
# ================================================================

retry_failed_packages() {

    while ((${#CURRENT_SECTION_FAILED[@]} > 0)); do

        echo
        echo -e "${RED}${BOLD}Failed packages:${RESET}"

        printf '  %s\n' "${CURRENT_SECTION_FAILED[@]}"

        echo

        if ! ask_yes_no "Retry failed packages ?"; then
            return 1
        fi

        local old_failed=("${CURRENT_SECTION_FAILED[@]}")

        CURRENT_SECTION_FAILED=()

        local package_id_value
        local manager
        local name
        local entry

        for package_id_value in "${old_failed[@]}"; do

            manager="${package_id_value%%:*}"
            name="${package_id_value#*:}"

            entry="$(find_package_entry "$name" "$manager")"

            if [[ -z "$entry" ]]; then

                CURRENT_SECTION_FAILED+=("$package_id_value")

                continue
            fi

            process_package "$entry"
        done


        if ((${#CURRENT_SECTION_FAILED[@]} > 0)); then

            echo
            warning "Some packages are still failing."

        else

            echo
            success "All failed packages were successfully retried."

            return 0
        fi
    done

    return 0
}


# ================================================================
# Section summary
# ================================================================

section_summary() {

    local section_name="$1"

    echo
    echo -e "${BOLD}${CYAN}Section summary: $section_name${RESET}"
    echo


    if ((${#CURRENT_SECTION_INSTALLED[@]} > 0)); then

        echo -e "${GREEN}${BOLD}INSTALLED / CONFIGURED:${RESET}"

        printf '  ✓ %s\n' "${CURRENT_SECTION_INSTALLED[@]}"

        echo
    fi


    if ((${#CURRENT_SECTION_SKIPPED[@]} > 0)); then

        echo -e "${YELLOW}${BOLD}SKIPPED / ALREADY INSTALLED:${RESET}"

        printf '  - %s\n' "${CURRENT_SECTION_SKIPPED[@]}"

        echo
    fi


    if ((${#CURRENT_SECTION_FAILED[@]} > 0)); then

        echo -e "${RED}${BOLD}FAILED:${RESET}"

        printf '  ✗ %s\n' "${CURRENT_SECTION_FAILED[@]}"

        echo
    fi


    if (( ${#CURRENT_SECTION_INSTALLED[@]} == 0 &&
        ${#CURRENT_SECTION_SKIPPED[@]} == 0 &&
        ${#CURRENT_SECTION_FAILED[@]} == 0 )); then

        info "Nothing to install for this section."
    fi
}


# ================================================================
# Install selected packages from a section
# ================================================================

install_section() {

    local section_number="$1"
    local section_name="${SECTION_NAMES[$((section_number - 1))]}"

    reset_section_results


    # ------------------------------------------------------------
    # Package selection.
    # ------------------------------------------------------------

    if ! select_section_packages "$section_number"; then
        return 0
    fi


    # ------------------------------------------------------------
    # Install selected packages.
    # ------------------------------------------------------------

    clear

    print_section_header "$section_number" "$section_name"

    echo -e "${BOLD}Installing selected packages...${RESET}"
    echo


    local entry

    for entry in "${SELECTED_PACKAGES[@]}"; do

        process_package "$entry"
    done


    # ------------------------------------------------------------
    # Retry failed packages.
    # ------------------------------------------------------------

    if ((${#CURRENT_SECTION_FAILED[@]} > 0)); then

        retry_failed_packages || true
    fi


    # ------------------------------------------------------------
    # Section summary.
    # ------------------------------------------------------------

    section_summary "$section_name"

    echo
    echo -e "${DIM}Press ENTER to continue...${RESET}"

    read -r
}


# ================================================================
# Install all sections
# ================================================================

install_all_sections() {

    local i

    for ((i = 1; i <= ${#SECTION_NAMES[@]}; i++)); do

        install_section "$i"
    done
}


# ================================================================
# Section selection menu
# ================================================================

section_menu() {

    while true; do

        clear

        print_header "Arch Dotfiles Installer"

        echo -e "Dotfiles:"
        echo -e "  ${DIM}$DOTFILES_DIR${RESET}"

        echo

        echo -e "${BOLD}Available sections:${RESET}"

        echo

        echo -e "  ${CYAN}0)${RESET} ALL SECTIONS"

        local i

        for ((i = 0; i < ${#SECTION_NAMES[@]}; i++)); do

            printf "  ${CYAN}%d)${RESET} %s\n" \
                "$((i + 1))" \
                "${SECTION_NAMES[$i]}"
        done

        echo

        echo -e "  ${CYAN}q)${RESET} Quit"

        echo

        local selection

        read -r -p "Select section: " selection

        case "$selection" in

            0)
                install_all_sections
                ;;

            1|2|3|4|5|6|7|8|9)
                install_section "$selection"
                ;;

            q|Q)
                break
                ;;

            *)
                warning "Invalid selection."
                sleep 1
                ;;
        esac
    done
}


# ================================================================
# Final summary
# ================================================================

final_summary() {

    clear

    print_header "Installation Summary"


    echo -e "${GREEN}${BOLD}INSTALLED / CONFIGURED${RESET}"

    if ((${#INSTALLED[@]} > 0)); then

        printf '  ✓ %s\n' "${INSTALLED[@]}"

    else

        echo "  None"
    fi


    echo

    echo -e "${YELLOW}${BOLD}SKIPPED / ALREADY INSTALLED${RESET}"

    if ((${#SKIPPED[@]} > 0)); then

        printf '  - %s\n' "${SKIPPED[@]}"

    else

        echo "  None"
    fi


    echo

    echo -e "${RED}${BOLD}FAILED${RESET}"

    if ((${#FAILED[@]} > 0)); then

        printf '  ✗ %s\n' "${FAILED[@]}"

    else

        echo "  None"
    fi


    echo


    if ((${#FAILED[@]} == 0)); then

        echo -e "${GREEN}${BOLD}✓ Installation completed successfully.${RESET}"

    else

        echo -e "${YELLOW}${BOLD}! Installation completed with failures.${RESET}"

        echo
        echo "Failed packages:"

        printf '  %s\n' "${FAILED[@]}"
    fi

    echo
}


# ================================================================
# Initial system preparation
# ================================================================

main() {

    clear

    print_header "Arch Dotfiles Installer"

    echo -e "${DIM}"
    echo "  Dotfiles: $DOTFILES_DIR"
    echo -e "${RESET}"


    check_arch

    prepare_sudo

    keep_sudo_alive


    echo

    if ! ask_yes_no "Update system with pacman -Syu ?"; then

        warning "Skipping system update."

    else

        print_header "Updating Arch Linux"

        if ! sudo pacman -Syu --noconfirm; then

            error "System update failed."

            echo

            if ! ask_yes_no "Continue anyway ?"; then
                exit 1
            fi
        fi
    fi


    echo


    # Make sure common configuration directories exist.

    mkdir -p \
        "$HOME/.config" \
        "$HOME/.local/bin"


    # npm global binaries.

    export PATH="$HOME/.npm/bin:$PATH"


    section_menu


    final_summary
}


# ================================================================
# Run
# ================================================================

main "$@"
