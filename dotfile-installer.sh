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
# NAME | MANAGER | PLATFORM | SECTION | DESCRIPTION | CONFIG | COMMAND
#
# MANAGER:
#   pacman
#   aur
#   npm
#   cargo
#   script
#   None
#
# PLATFORM:
#   arch
#   wsl
#   arch,wsl
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
# NAME | MANAGER | PLATFORM | SECTION | DESCRIPTION | CONFIG | COMMAND
# ================================================================

PACKAGES=(

    # ═════════════════════════════════════════════════════════════
    # Hardware & Drivers
    # Section 1
    # ═════════════════════════════════════════════════════════════

    "nvidia-open|pacman|arch|1|Open NVIDIA kernel module||"
    "nvidia-utils|pacman|arch|1|NVIDIA userspace utilities and libraries||"
    "vulkan-tools|pacman|arch|1|Vulkan diagnostic and information utilities||"

    "pipewire|pacman|arch|1|Modern Linux audio and video framework||command:systemctl --user enable --now pipewire.service && systemctl --user enable --now pipewire-pulse.service"
    "pipewire-pulse|pacman|arch|1|PulseAudio compatibility layer using PipeWire||"
    "pipewire-audio|pacman|arch|1|PipeWire audio support||"
    "pipewire-alsa|pacman|arch|1|ALSA support through PipeWire||"
    "pipewire-jack|pacman|arch|1|JACK compatibility through PipeWire||"

    "wireplumber|pacman|arch|1|PipeWire session and policy manager||command:systemctl --user enable --now wireplumber.service"

    "pavucontrol|pacman|arch|1|GTK volume and audio device controller||"

    "networkmanager|pacman|arch|1|Network connection manager||"
    "network-manager-applet|pacman|arch|1|NetworkManager graphical tray applet||"
    "networkmanager-openvpn|pacman|arch|1|OpenVPN support for NetworkManager||"

    "bluez|pacman|arch|1|Linux Bluetooth protocol stack||"
    "bluez-utils|pacman|arch|1|Bluetooth command-line utilities||"
    "blueman|pacman|arch|1|GTK Bluetooth device manager||"

    "mtpfs|pacman|arch|1|FUSE filesystem for mounting MTP devices such as Android phones||"
    "gvfs-mtp|pacman|arch|1|GVFS support for MTP devices such as Android phones||"
    "gvfs-gphoto2|pacman|arch|1|GVFS support for cameras and PTP devices||"


    # ═════════════════════════════════════════════════════════════
    # Hyprland / Wayland
    # Section 2
    # ═════════════════════════════════════════════════════════════

    "ly|pacman|arch|2|Lightweight terminal display manager||"

    "hyprland|pacman|arch|2|Dynamic tiling Wayland compositor|config:.config/hypr=>~/.config/hyprland|"

    "xdg-desktop-portal|pacman|arch|2|Desktop integration portal framework||"
    "xdg-desktop-portal-hyprland|pacman|arch|2|XDG desktop portal backend for Hyprland||"
    "xdg-desktop-portal-gtk|pacman|arch|2|GTK XDG desktop portal backend||"

    "hyprpicker|pacman|arch|2|Color picker for Hyprland and Wayland||"
    "hyprpaper|pacman|arch|2|Fast Wayland wallpaper utility||"
    "hyprpolkitagent|pacman|arch|2|Polkit authentication agent for Hyprland||"
    "hypridle|pacman|arch|2|Idle management daemon for Hyprland||"
    "wlogout|pacman|arch|2|Wayland logout and power menu||"

    "qt5-wayland|pacman|arch|2|Wayland platform plugin for Qt5||"
    "qt6-wayland|pacman|arch|2|Wayland platform plugin for Qt6||"
    "qt6ct|pacman|arch|2|Qt6 configuration utility||"


    # ═════════════════════════════════════════════════════════════
    # Desktop Essentials
    # Section 3
    # ═════════════════════════════════════════════════════════════

    "rofi|pacman|arch|3|Application launcher|config:.config/rofi=>~/.config/rofi|"
    "dunst|pacman|arch|3|Lightweight desktop notification daemon|config:.config/dunst=>~/.config/dunst;.config/systemd/user/dunst.service=>~/.config/systemd/user/dunst.service|command:systemctl --user daemon-reload && systemctl --user enable --now dunst.service"

    "nwg-look|pacman|arch|3|GTK theme configuration utility for Wayland||"
    "gnome-themes-extra|pacman|arch|3|Additional GNOME and GTK themes||"

    "wl-clipboard|pacman|arch|3|Wayland clipboard command-line utilities||"
    "clipse|pacman|arch|3|TUI clipboard manager for Wayland|config:.config/systemd/user/clipse.service=>~/.config/systemd/user/clipse.service|command:systemctl --user daemon-reload && systemctl --user enable --now clipse.service"

    "grim|pacman|arch|3|Screenshot utility for Wayland||"
    "slurp|pacman|arch|3|Interactive Wayland region selector||"
    "swappy|pacman|arch|3|Wayland screenshot annotation tool||"

    "udiskie|pacman|arch|3|Removable-disk automounter|config:.config/systemd/user/udiskie.service=>~/.config/systemd/user/udiskie.service|command:systemctl --user daemon-reload && systemctl --user enable --now udiskie.service"
    "udisks2|pacman|arch|3|Disk management service||"

    "imv|pacman|arch|3|Simple image viewer with Wayland support||"

    "mpv|pacman|arch|3|Powerful command-line media player|config:.config/mpv=>~/.config/mpv|"
    "mpv-mpris|pacman|arch|3|MPRIS support for MPV||"

    "ffmpeg|pacman|arch,wsl|3|Audio and video processing framework||"
    "ffmpegthumbnailer|pacman|arch,wsl|3|Video thumbnail generator||"

    "poppler|pacman|arch,wsl|3|PDF rendering and processing tools||"

    "zathura|pacman|arch|3|Minimalist document viewer|config:.config/zathura=>~/.config/zathura|"
    "zathura-pdf-mupdf|pacman|arch|3|PDF backend for Zathura||"

    "gammastep|pacman|arch|3|Screen color temperature and brightness adjustment||"


    # ═════════════════════════════════════════════════════════════
    # Waybar
    # Section 4
    # ═════════════════════════════════════════════════════════════

    "waybar|pacman|arch|4|Highly customizable Wayland status bar|config:.config/waybar=>~/.config/waybar|"

    "inotify-tools|pacman|arch|4|Filesystem event monitoring utilities||"
    "python-setuptools|pacman|arch|4|Python package build and installation utilities||"
    "zscroll|aur|arch|4|Scrolling text utility for status bars||"
    "playerctl|pacman|arch|4|Command-line MPRIS media player controller|config:.config/systemd/user/playerctl.service=>~/.config/systemd/user/playerctl.service|command:systemctl --user daemon-reload && systemctl --user enable --now playerctl.service"
    "brightnessctl|pacman|arch|4|Backlight and brightness control utility||"
    "geoip|pacman|arch|4|GeoIP database and lookup utilities||"

    "curl|pacman|arch,wsl|4|Command-line HTTP and data transfer utility||"
    "awk|pacman|arch,wsl|4|Text processing language and utility||"
    "coreutils|pacman|arch,wsl|4|Core GNU command-line utilities||"

    "waybar-lyric|aur|arch|4|Waybar lyrics module||"

    "jq|pacman|arch,wsl|4|Command-line JSON processor||"
    "bc|pacman|arch,wsl|4|Arbitrary precision calculator||"
    "htop|pacman|arch,wsl|4|Interactive process viewer||"


    # ═════════════════════════════════════════════════════════════
    # Fonts
    # Section 5
    # ═════════════════════════════════════════════════════════════

    "noto-fonts|pacman|arch|5|Noto font family||"
    "noto-fonts-emoji|pacman|arch|5|Noto emoji font||"
    "noto-fonts-cjk|pacman|arch|5|Noto fonts for Chinese Japanese and Korean text||"

    "ttf-firacode-nerd|pacman|arch|5|FiraCode Nerd Font with programming symbols||"
    "ttf-jetbrains-mono-nerd|pacman|arch|5|JetBrains Mono Nerd Font||"

    "woff2-font-awesome|aur|arch|5|Font Awesome WOFF2 icon font||"
    "inter-font|pacman|arch|5|Inter UI font||"
    # "fontconfig|None|arch|5|Font aliases and settings|config:.config/fontconfig=>~/.config/fontconfig|command:fc-cache -f"


    # ═════════════════════════════════════════════════════════════
    # Shell
    # Section 6
    # ═════════════════════════════════════════════════════════════

    "zsh|pacman|arch,wsl|6|ZSH shell||command:chsh -s \"$(command -v zsh)\""

    "zsh-theme-powerlevel10k|aur|arch,wsl|6|Powerlevel10k theme for Zsh|config:.p10k.zsh=>~/.p10k.zsh|"

    "oh-my-zsh|None|arch,wsl|6|Zsh configuration framework||command:if [[ ! -d \"\$HOME/.oh-my-zsh\" ]]; then RUNZSH=no CHSH=no sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"; fi"

    "zsh-autosuggestions|pacman|arch,wsl|6|Fish-like autosuggestions for Zsh||"
    "zsh-syntax-highlighting|pacman|arch,wsl|6|Syntax highlighting for Zsh||"

    "tmux|pacman|arch,wsl|6|Terminal multiplexer|config:.config/tmux=>~/.config/tmux|command:if [[ ! -d \"$HOME/.config/tmux/plugins/tpm\" ]]; then git clone https://github.com/tmux-plugins/tpm \"$HOME/.config/tmux/plugins/tpm\"; fi"


    # ═════════════════════════════════════════════════════════════
    # Terminal & CLI
    # Section 7
    # ═════════════════════════════════════════════════════════════

    "yazi|aur|arch,wsl|7|Terminal file manager|config:.config/yazi=>~/.config/yazi|command:cd \"$HOME/.config/yazi\" && ya pkg add yazi-rs/plugins:full-border imsi32/yatline MasouShizuka/projects DreamoMaoMao/fg AnirudhG07/plugins-yazi:copy-file-contents Lil-Dank/lazygit pirafrank/what-size"

    "mediainfo|pacman|arch,wsl|7|Media metadata inspector||"
    "imagemagick|pacman|arch,wsl|7|Image manipulation toolkit||"
    "ripgrep|pacman|arch,wsl|7|Fast recursive search tool||"
    "fd|pacman|arch,wsl|7|Fast find alternative||"
    "fzf|pacman|arch,wsl|7|Command-line fuzzy finder||"
    "zoxide|pacman|arch,wsl|7|Smarter cd command||"
    "tldr|pacman|arch,wsl|7|Simplified command-line documentation||"
    "aria2|pacman|arch,wsl|7|Multi-protocol download utility||"

    "tree|pacman|arch,wsl|7|Directory tree viewer||"
    "lsd|pacman|arch,wsl|7|Modern ls replacement||"
    "eza|pacman|arch,wsl|7|Modern replacement for ls||"

    "unrar|pacman|arch,wsl|7|RAR archive extraction utility||"
    "unzip|pacman|arch,wsl|7|ZIP archive extraction utility||"
    "tar|pacman|arch,wsl|7|Archive utility||"
    "p7zip|pacman|arch,wsl|7|7-Zip archive support||"

    "ntfsprogs|pacman|arch|7|NTFS filesystem utilities||"

    "yt-dlp|pacman|arch,wsl|7|Media downloader||"
    "lf|pacman|arch,wsl|7|Terminal file manager||"

    "lazygit|pacman|arch,wsl|7|Terminal UI for Git||"
    "lazydocker|pacman|arch,wsl|7|Terminal UI for Docker||"

    "github-cli|pacman|arch,wsl|7|GitHub command-line interface||command:gh auth login"


    # ═════════════════════════════════════════════════════════════
    # Development
    # Section 8
    # ═════════════════════════════════════════════════════════════

    "git|pacman|arch,wsl|8|Distributed version control system||"
    "clang|pacman|arch,wsl|8|LLVM C/C++ compiler||"
    "llvm|pacman|arch,wsl|8|LLVM compiler infrastructure||"

    "neovim|pacman|arch,wsl|8|Extensible terminal text editor|config:.config/nvim=>~/.config/nvim|command:nvim --headless \"+Lazy! sync\" +qa"

    "python|pacman|arch,wsl|8|Python programming language||"
    "python-pip|pacman|arch,wsl|8|Python package installer||"
    "uv|pacman|arch,wsl|8|Extremely fast Python package installer||"

    "python-pynvim|pacman|arch,wsl|8|Python client for Neovim||"
    "python-ipykernel|pacman|arch,wsl|8|Jupyter Python kernel||"
    "python-pillow|pacman|arch,wsl|8|Python imaging library||"
    "python-cairosvg|pacman|arch,wsl|8|SVG renderer for Python||"
    "python-pyperclip|pacman|arch,wsl|8|Python clipboard library||"

    "pyright|aur|arch,wsl|8|Python type checker and language server||"

    "nodejs|pacman|arch,wsl|8|JavaScript runtime||"
    "npm|pacman|arch,wsl|8|Node.js package manager||command:mkdir -p \"$HOME/.npm\" && npm config set prefix \"$HOME/.npm\""

    "bun|pacman|arch,wsl|8|JavaScript runtime and package manager||"
    "yarn|pacman|arch,wsl|8|JavaScript package manager||"

    "rustup|pacman|arch,wsl|8|Rust toolchain installer||"
    "rust-analyzer|pacman|arch,wsl|8|Rust language server||"
    "lldb|pacman|arch,wsl|8|LLVM debugger||"

    "tree-sitter-cli|cargo|arch,wsl|8|Tree-sitter command-line interface||"

    "docker|pacman|arch|8|Container engine||command:sudo groupadd -f docker && sudo usermod -aG docker \"$USER\""
    "docker-compose|pacman|arch|8|Docker Compose integration||"
    "docker-buildx|pacman|arch|8|Docker Buildx plugin||"

    "typescript|pacman|arch,wsl|8|TypeScript language||"

    "typescript-language-server|aur|arch,wsl|8|TypeScript language server||"
    "vim-language-server|aur|arch,wsl|8|Vim language server||"

    "vscode-langservers-extracted|npm|arch,wsl|8|HTML CSS and JSON language servers||"
    "emmet-ls|npm|arch,wsl|8|Emmet language server||"
    "bash-language-server|npm|arch,wsl|8|Bash language server||"
    "yaml-language-server|npm|arch,wsl|8|YAML language server||"

    "neovim|npm|arch,wsl|8|Neovim Node.js provider||"

    "biome|npm|arch,wsl|8|JavaScript and TypeScript formatter and linter||"
    "prettier|npm|arch,wsl|8|Code formatter||"

    "opencode|pacman|arch,wsl|8|AI-powered coding agent for the terminal|config:.config/opencode=>~/.config/opencode|"
    "herdr-bin|aur|arch,wsl|8|Command-line utility|config:.config/herdr=>~/.config/herdr|"


    # ═════════════════════════════════════════════════════════════
    # Applications
    # Section 9
    # ═════════════════════════════════════════════════════════════

    "kitty|pacman|arch|9|GPU-accelerated terminal emulator|config:.config/kitty=>~/.config/kitty|"

    "nautilus|pacman|arch|9|GNOME file manager||"
    "file-roller|pacman|arch|9|Archive manager||"

    "zen-browser-bin|aur|arch|9|Privacy-focused Firefox-based web browser||"

    "telegram-desktop|pacman|arch|9|Telegram desktop client||"
    "gnome-calculator|pacman|arch|9|GNOME calculator application||"
    "zed|pacman|arch|9|High-performance modern code editor|config:.config/zed=>~/.config/zed|"
    "visual-studio-code-bin|aur|arch|9|Microsoft Visual Studio Code binary package||"
    "obsidian|pacman|arch|9|Markdown knowledge-management application||"

    "ocrdesktop|pacman|arch|9|Desktop OCR utility||"
    "tesseract-data-eng|pacman|arch|9|English OCR language data||"

    "windscribe|None|arch|9|windscribe VPN|config:.config/systemd/user/windscribe.service=>~/.config/systemd/user/windscribe.service|command:systemctl --user daemon-reload && systemctl --user enable --now windscribe.service"

    "mimeapps.list|None|arch|9|MIME type associations|config:.config/mimeapps.list=>~/.config/mimeapps.list"

    "spotify|aur|arch|9|Spotify client|config:applications/spotify.desktop=>~/.local/share/applications/spotify.desktop|command:update-desktop-database ~/.local/share/applications"

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
# Detect platform
# ================================================================

detect_platform() {

    if [[ -f /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version; then
        PLATFORM="wsl"
    else
        PLATFORM="arch"
    fi

    info "Detected platform: ${BOLD}${PLATFORM}${RESET}"
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

    if ! sudo pacman -S --needed --noconfirm base-devel git; then
        error "Failed to install base-devel/git."
        return 1
    fi

    local tmp_dir

    tmp_dir="$(mktemp -d)"

    info "Cloning yay..."

    if ! git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"; then
        error "Failed to clone yay."
        rm -rf "$tmp_dir"
        return 1
    fi

    info "Building and installing yay..."

    if ! (
        cd "$tmp_dir/yay" &&
        makepkg -si --noconfirm
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
# Install package
# ================================================================

install_package() {

    local name="$1"
    local manager="$2"

    case "$manager" in

        pacman)

            info "Installing ${BOLD}$name${RESET} with pacman..."

            sudo pacman -S --needed --noconfirm "$name"
            ;;


        aur)

            if ! command -v yay >/dev/null 2>&1; then
                ensure_yay || return 1
            fi

            info "Installing ${BOLD}$name${RESET} from AUR..."

            yay -S --needed --noconfirm "$name"
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

            npm install -g "$name"
            ;;


        cargo)

            if ! command -v cargo >/dev/null 2>&1; then
                error "cargo is not installed."
                return 1
            fi

            info "Installing ${BOLD}$name${RESET} with cargo..."

            cargo install --locked "$name"
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

    bash -c "$command"
}


# ================================================================
# Parse package entry
# ================================================================

parse_package() {

    local entry="$1"

    IFS='|' read -r \
        PKG_NAME \
        PKG_MANAGER \
        PKG_PLATFORM \
        PKG_SECTION \
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
# Check whether package belongs to current platform
# ================================================================

platform_matches() {

    local platforms="$1"

    [[ ",$platforms," == *",$PLATFORM,"* ]]
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

        IFS='|' read -r name manager _ <<< "$entry"

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
    # Collect packages for this section and platform.
    # ------------------------------------------------------------

    for entry in "${PACKAGES[@]}"; do

        parse_package "$entry"

        if [[ "$PKG_SECTION" != "$section_number" ]]; then
            continue
        fi

        if ! platform_matches "$PKG_PLATFORM"; then
            continue
        fi

        section_entries+=("$entry")
    done


    # ------------------------------------------------------------
    # Nothing available.
    # ------------------------------------------------------------

    if ((${#section_entries[@]} == 0)); then

        warning "No packages are available for this section on platform: $PLATFORM"

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


                if (
                    (start < 1) ||
                    (end > ${#section_entries[@]}) ||
                    (start > end)
                ); then

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

    if ! platform_matches "$PKG_PLATFORM"; then
        return 0
    fi

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


    if (
        ((${#CURRENT_SECTION_INSTALLED[@]} == 0)) &&
        ((${#CURRENT_SECTION_SKIPPED[@]} == 0)) &&
        ((${#CURRENT_SECTION_FAILED[@]} == 0))
    ); then

        info "Nothing to install for this platform."
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

        echo -e "Platform:"
        echo -e "  ${BOLD}$PLATFORM${RESET}"

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

    detect_platform

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
