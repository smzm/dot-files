#!/usr/bin/env python3
"""
Dotfiles Installer
==================
Self-bootstrapping · live install output · auto-detects WSL vs Arch
· fetches package descriptions from AUR API + pacman before selection
"""
import os
import subprocess
import sys
from pathlib import Path

# ─────────────────────────────────────────────────────────────────────────────
# SELF-BOOTSTRAP — create venv + install deps, then re-exec inside it
# ─────────────────────────────────────────────────────────────────────────────
VENV_DIR = Path(__file__).parent / ".installer_venv"
REQUIRED = ["rich", "inquirer"]
def _bootstrap():
    if sys.prefix != sys.base_prefix:
        return # already inside our venv
    if not VENV_DIR.exists():
        print("⚙ First run — setting up installer environment…")
        subprocess.run([sys.executable, "-m", "venv", str(VENV_DIR)], check=True)
    pip = VENV_DIR / "bin" / "pip"
    subprocess.run([str(pip), "install", "--quiet", "--upgrade", *REQUIRED], check=True)
    os.execv(str(VENV_DIR / "bin" / "python"),
             [str(VENV_DIR / "bin" / "python")] + sys.argv)
_bootstrap()
import concurrent.futures
import json
# ─────────────────────────────────────────────────────────────────────────────
# Imports (available after bootstrap)
# ─────────────────────────────────────────────────────────────────────────────
import re
import urllib.parse
import urllib.request

import inquirer
from rich import print as rprint
from rich.columns import Columns
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Confirm

console = Console()
DOTFILES = Path(__file__).parent.resolve()
# ─────────────────────────────────────────────────────────────────────────────
# Auto-detect environment
# ─────────────────────────────────────────────────────────────────────────────
def detect_env() -> str:
    """Return 'wsl' or 'arch' by inspecting /proc/version."""
    try:
        v = Path("/proc/version").read_text().lower()
        if "microsoft" in v or "wsl" in v:
            return "wsl"
    except FileNotFoundError:
        pass
    return "arch"
# ─────────────────────────────────────────────────────────────────────────────
# Package registry
#
# name        : package identifier
# env         : "arch" | "wsl" | "both"
# aur         : True → prefer yay; fall back to pacman if yay unavailable
#               False → pacman only
# description : human-readable description of the package
# ─────────────────────────────────────────────────────────────────────────────
PACKAGES = [
    # ── core utilities (both) ─────────────────────────────────────────────────
    {"name": "git",                    "env": "both", "aur": False, "description": "Fast distributed version control system"},
    {"name": "wget",                   "env": "both", "aur": False, "description": "Network utility to retrieve files from the web"},
    {"name": "curl",                   "env": "both", "aur": False, "description": "Command-line tool for transferring data with URLs"},
    {"name": "openssh",                "env": "both", "aur": False, "description": "SSH protocol implementation for remote login, command execution and file transfer"},
    {"name": "binutils",               "env": "both", "aur": False, "description": "A set of programs to assemble and manipulate binary and object files"},
    {"name": "base-devel",             "env": "both", "aur": False, "description": "Basic tools to build Arch Linux packages"},
    {"name": "pkgconf",                "env": "both", "aur": False, "description": "Package compiler and linker metadata toolkit"},
    {"name": "unrar",                  "env": "both", "aur": False, "description": "The RAR uncompression program"},
    {"name": "unzip",                  "env": "both", "aur": False, "description": "For extracting and viewing files in .zip archives"},
    {"name": "tar",                    "env": "both", "aur": False, "description": "Utility used to store, backup, and transport files"},
    {"name": "p7zip",                  "env": "both", "aur": False, "description": "File archiver for extremely high compression"},
    {"name": "jq",                     "env": "both", "aur": False, "description": "Command-line JSON processor"},
    {"name": "fd",                     "env": "both", "aur": False, "description": "Simple, fast and user-friendly alternative to find"},
    {"name": "fzf",                    "env": "both", "aur": False, "description": "Command-line fuzzy finder"},
    {"name": "zoxide",                 "env": "both", "aur": False, "description": "A smarter cd command for your terminal"},
    {"name": "ripgrep",                "env": "both", "aur": False, "description": "A search tool that combines the usability of ag with the raw speed of grep"},
    {"name": "bat",                    "env": "both", "aur": False, "description": "cat clone with syntax highlighting and Git integration"},
    {"name": "eza",                    "env": "both", "aur": False, "description": "A modern replacement for ls (community fork of exa)"},
    {"name": "lsd",                    "env": "both", "aur": False, "description": "Modern ls with a lot of pretty colors and awesome icons"},
    {"name": "htop",                   "env": "both", "aur": False, "description": "Interactive process viewer"},
    {"name": "tmux",                   "env": "both", "aur": False, "description": "Terminal multiplexer"},
    {"name": "zsh",                    "env": "both", "aur": False, "description": "A very advanced and programmable command interpreter (shell) for UNIX"},
    {"name": "starship",               "env": "both", "aur": False, "description": "The cross-shell prompt for astronauts"},
    {"name": "aria2",                  "env": "both", "aur": False, "description": "Download utility that supports HTTP(S), FTP, BitTorrent, and Metalink"},
    {"name": "fzy",                    "env": "both", "aur": False, "description": "A better fuzzy finder"},
    {"name": "peco",                   "env": "both", "aur": False, "description": "Simplistic interactive filtering tool"},
    {"name": "tldr",                   "env": "both", "aur": False, "description": "Command line client for tldr, a collection of simplified man pages."},
    {"name": "imagemagick",            "env": "both", "aur": False, "description": "An image viewing/manipulation program"},
    {"name": "ffmpeg",                 "env": "both", "aur": False, "description": "Complete solution to record, convert and stream audio and video"},
    {"name": "ffmpegthumbnailer",      "env": "both", "aur": False, "description": "Lightweight video thumbnailer that can be used by file managers"},
    {"name": "poppler",                "env": "both", "aur": False, "description": "PDF rendering library based on xpdf 3.0"},
    {"name": "tk",                     "env": "both", "aur": False, "description": "A windowing toolkit for use with tcl"},
    {"name": "mediainfo",              "env": "both", "aur": False, "description": "Supplies technical and tag information about media files (CLI interface)"},
    {"name": "yt-dlp",                 "env": "both", "aur": False, "description": "A youtube-dl fork with additional features and fixes"},
    {"name": "newsboat",               "env": "both", "aur": False, "description": "RSS/Atom feed reader for text terminals"},
    {"name": "github-cli",             "env": "both", "aur": False, "description": "The GitHub CLI"},
    {"name": "lazygit",                "env": "both", "aur": False, "description": "Simple terminal UI for git commands"},
    {"name": "lazydocker",             "env": "both", "aur": False, "description": "A simple terminal UI for docker and docker-compose, written in Go with the gocui library."},
    {"name": "neovim",                 "env": "both", "aur": False, "description": "Fork of Vim aiming to improve user experience, plugins, and GUIs"},
    {"name": "luarocks",               "env": "both", "aur": False, "description": "Deployment and management system for Lua modules"},
    {"name": "lldb",                   "env": "both", "aur": False, "description": "Next generation, high-performance debugger"},
    {"name": "yazi",                   "env": "both", "aur": False,  "description": "Blazing fast terminal file manager written in Rust, based on async I/O"},
    {"name": "postgresql-libs",        "env": "both", "aur": False, "description": "Sophisticated object-relational DBMS - Client binaries and libraries"},
    # ── python (both) ─────────────────────────────────────────────────────────
    {"name": "python",                 "env": "both", "aur": False, "description": "The Python programming language"},
    {"name": "python-pip",             "env": "both", "aur": False, "description": "The PyPA recommended tool for installing Python packages"},
    {"name": "python-pynvim",          "env": "both", "aur": False, "description": "Python client for Neovim"},
    {"name": "python-ipykernel",       "env": "both", "aur": False, "description": "The ipython kernel for Jupyter"},
    {"name": "python-pillow",          "env": "both", "aur": False, "description": "Python Imaging Library (PIL) fork"},
    {"name": "python-cairosvg",        "env": "both", "aur": False, "description": "SVG converter based on Cairo. It can export SVG files to PDF, PostScript and PNG files"},
    {"name": "python-pyperclip",       "env": "both", "aur": False, "description": "A cross-platform clipboard module for Python"},
    {"name": "pyenv",                  "env": "both", "aur": False, "description": "Easily switch between multiple versions of Python"},
    {"name": "jupyter-notebook",       "env": "both", "aur": False, "description": "The language-agnostic HTML notebook application for Project Jupyter"},
    {"name": "uv",                     "env": "both", "aur": False, "description": "An extremely fast Python package installer and resolver written in Rust"},
    {"name": "ruff",                   "env": "both", "aur": False, "description": "An extremely fast Python linter, written in Rust"},
    # ── node / js (both) ──────────────────────────────────────────────────────
    {"name": "nodejs",                 "env": "both", "aur": False, "description": "Evented I/O for V8 javascript (Current release)"},
    {"name": "npm",                    "env": "both", "aur": False, "description": "JavaScript package manager"},
    {"name": "yarn",                   "env": "both", "aur": False, "description": "Fast, reliable, and secure dependency management"},
    {"name": "bun",                    "env": "both", "aur": False, "description": "Incredibly fast JavaScript runtime, bundler, test runner, and package manager – all in one"},
    # ── rust (both) ───────────────────────────────────────────────────────────
    {"name": "rustup",                 "env": "both", "aur": False, "description": "The Rust toolchain installer"},
    {"name": "rust-analyzer",          "env": "both", "aur": False, "description": "Rust compiler front-end for IDEs"},
    # ── fonts (both) ──────────────────────────────────────────────────────────
    {"name": "ttf-firacode-nerd",      "env": "both", "aur": False, "description": "Patched font Fira (Fura) Code from nerd fonts library"},
    {"name": "ttf-jetbrains-mono",     "env": "both", "aur": False, "description": "Typeface for developers, by JetBrains"},
    # ── AUR — both envs ───────────────────────────────────────────────────────
    {"name": "tailwindcss",            "env": "both", "aur":  True,  "description": "A utility-first CSS framework for rapidly building custom user interfaces."},
    {"name": "trashy",                 "env": "both", "aur": True,  "description": "a cli system trash manager, alternative to rm and trash-cli"},
    {"name": "pnglatex",               "env": "both", "aur": True,  "description": "Small script to turn LaTeX formulas into png images"},
    {"name": "dtop-bin",               "env": "both", "aur": True,  "description": "Terminal dashboard for Docker"},
    {"name": "tuxedo-bin",             "env": "both", "aur": True,  "description": "A fast, keyboard-driven terminal UI for todo.txt"},
    # ── WSL-specific ──────────────────────────────────────────────────────────
    {"name": "xsel",                   "env": "wsl",  "aur": False, "description": "a command-line program for getting and setting the contents of the X selection"},
    {"name": "xdg-utils",              "env": "wsl",  "aur": False, "description": "Tools for desktop integration (xdg-open, xdg-mime, etc.)"},
    # ── Arch-specific (pacman) ────────────────────────────────────────────────
    {"name": "yajl",                   "env": "arch", "aur": False, "description": "A fast streaming JSON parsing library in C"},
    {"name": "network-manager-applet", "env": "arch", "aur": False, "description": "Applet for managing network connections"},
    {"name": "networkmanager-openvpn", "env": "arch", "aur": False, "description": "NetworkManager plugin for OpenVPN connections"},
    {"name": "lightdm",                "env": "arch", "aur": False, "description": "A lightweight display manager"},
    {"name": "lightdm-gtk-greeter",    "env": "arch", "aur": False, "description": "GTK+ greeter for LightDM"},
    {"name": "ruby",                   "env": "arch", "aur": False, "description": "An object-oriented language for quick and easy programming"},
    {"name": "xclip",                  "env": "arch", "aur": False, "description": "Command line interface to the X11 clipboard"},
    {"name": "cronie",                 "env": "arch", "aur": False, "description": "Daemon that runs specified programs at scheduled times and related tools"},
    {"name": "unarchiver",             "env": "arch", "aur": False, "description": "unar and lsar: Objective-C tools for uncompressing archive files"},
    {"name": "lostfiles",              "env": "arch", "aur": False, "description": "Find orphaned files not owned by any Arch packages"},
    {"name": "opencode",               "env": "arch", "aur": False, "description": "The open source coding agent"},
    {"name": "gnome-calculator",       "env": "arch", "aur": False, "description": "GNOME Scientific calculator"},
    {"name": "kitty",                  "env": "arch", "aur": False, "description": "A modern, hackable, featureful, OpenGL-based terminal emulator"},
    {"name": "zathura",                "env": "arch", "aur": False, "description": "Minimalistic document viewer"},
    {"name": "zathura-pdf-mupdf",      "env": "arch", "aur": False, "description": "PDF support for Zathura (MuPDF backend) (Supports PDF, ePub, and OpenXPS)"},
    {"name": "mpv",                    "env": "arch", "aur": False, "description": "a free, open source, and cross-platform media player"},
    {"name": "mpv-mpris",              "env": "arch", "aur": False, "description": "MPRIS plugin for mpv"},
    {"name": "xbindkeys",              "env": "arch", "aur": False, "description": "Launch shell commands with your keyboard or your mouse under X"},
    {"name": "xorg-xev",               "env": "arch", "aur": False, "description": "Print contents of X events"},
    {"name": "xdotool",                "env": "arch", "aur": False, "description": "Command-line X11 automation tool"},
    {"name": "nemo",                   "env": "arch", "aur": False, "description": "File manager for Cinnamon (Nautilus fork)"},
    {"name": "lxappearance",           "env": "arch", "aur": False, "description": "Feature-rich GTK theme switcher of the LXDE Desktop"},
    {"name": "viewnior",               "env": "arch", "aur": False, "description": "A simple, fast and elegant image viewer program"},
    {"name": "gtk3",                   "env": "arch", "aur": False, "description": "GObject-based multi-platform GUI toolkit"},
    {"name": "ntfs-3g",                "env": "arch", "aur": False, "description": "NTFS FUSE driver"},
    {"name": "exfat-utils",            "env": "arch", "aur": False, "description": "Utilities for exFAT file system"},
    {"name": "i3-wm",                  "env": "arch", "aur": False, "description": "Improved dynamic tiling window manager"},
    {"name": "python-i3ipc",           "env": "arch", "aur": False, "description": "An improved Python library to control i3wm"},
    {"name": "arandr",                 "env": "arch", "aur": False, "description": "Provide a simple visual front end for XRandR 1.2."},
    {"name": "rofi",                   "env": "arch", "aur": False, "description": "A window switcher, application launcher and dmenu replacement"},
    {"name": "python-pywal",           "env": "arch", "aur": False, "description": "Generate and change colorschemes on the fly"},
    {"name": "calc",                   "env": "arch", "aur": False, "description": "Arbitrary precision console calculator"},
    {"name": "bc",                     "env": "arch", "aur": False, "description": "An arbitrary precision calculator language"},
    {"name": "wmctrl",                 "env": "arch", "aur": False, "description": "Control your EWMH compliant window manager from command line"},
    {"name": "geoip",                  "env": "arch", "aur": False, "description": "Non-DNS IP-to-country resolver C library & utils"},
    {"name": "dunst",                  "env": "arch", "aur": False, "description": "Customizable and lightweight notification-daemon"},
    {"name": "libnotify",              "env": "arch", "aur": False, "description": "Library for sending desktop notifications"},
    {"name": "redshift",               "env": "arch", "aur": False, "description": "Adjusts the color temperature of your screen according to your surroundings."},
    {"name": "imwheel",                "env": "arch", "aur": False, "description": "Mouse wheel configuration tool for XFree86/Xorg"},
    {"name": "numlockx",               "env": "arch", "aur": False, "description": "Turns on the numlock key in X11."},
    {"name": "unclutter",              "env": "arch", "aur": False, "description": "A small program for hiding the mouse cursor"},
    {"name": "xcolor",                 "env": "arch", "aur": False, "description": "Lightweight color picker for X11"},
    {"name": "conky",                  "env": "arch", "aur": False, "description": "Light-weight system monitor for X, Wayland, and other things, too"},
    {"name": "pulseaudio",             "env": "arch", "aur": False, "description": "A featureful, general-purpose sound server"},
    {"name": "pulseaudio-alsa",        "env": "arch", "aur": False, "description": "ALSA Configuration for PulseAudio"},
    {"name": "pulseaudio-equalizer",   "env": "arch", "aur": False, "description": "Graphical equalizer for PulseAudio"},
    {"name": "pulseaudio-jack",        "env": "arch", "aur": False, "description": "Jack support for PulseAudio"},
    {"name": "pulseaudio-bluetooth",   "env": "arch", "aur": False, "description": "Bluetooth support for PulseAudio"},
    {"name": "alsa-utils",             "env": "arch", "aur": False, "description": "Advanced Linux Sound Architecture - Utilities"},
    {"name": "alsa-firmware",          "env": "arch", "aur": False, "description": "Firmware binaries for loader programs in alsa-tools and hotplug firmware loader"},
    {"name": "xdg-desktop-portal",     "env": "arch", "aur": False, "description": "Desktop integration portals for sandboxed apps"},
    {"name": "xdg-desktop-portal-gtk", "env": "arch", "aur": False, "description": "A backend implementation for xdg-desktop-portal using GTK"},
    {"name": "pavucontrol",            "env": "arch", "aur": False, "description": "PulseAudio Volume Control"},
    {"name": "bluez",                  "env": "arch", "aur": False, "description": "Daemons for the bluetooth protocol stack"},
    {"name": "bluez-utils",            "env": "arch", "aur": False, "description": "Development and debugging utilities for the bluetooth protocol stack"},
    {"name": "blueman",                "env": "arch", "aur": False, "description": "GTK+ Bluetooth Manager"},
    {"name": "feh",                    "env": "arch", "aur": False, "description": "Fast and light imlib2-based image viewer"},
    {"name": "mtpfs",                  "env": "arch", "aur": False, "description": "A FUSE filesystem that supports reading and writing from any MTP device"},
    {"name": "gvfs-mtp",               "env": "arch", "aur": False, "description": "Virtual filesystem implementation for GIO - MTP backend (Android, media player)"},
    {"name": "gvfs-gphoto2",           "env": "arch", "aur": False, "description": "Virtual filesystem implementation for GIO - gphoto2 backend (PTP camera, MTP media player)"},
    {"name": "gnome-keyring",          "env": "arch", "aur": False, "description": "Stores passwords and encryption keys"},
    {"name": "inter-font",             "env": "arch", "aur": False, "description": "A typeface specially designed for user interfaces"},
    {"name": "usbutils",               "env": "arch", "aur": False, "description": "A collection of USB tools to query connected USB devices"},
    {"name": "udisks2",                "env": "arch", "aur": False, "description": "Daemon, tools and libraries to access and manipulate disks, storage devices and technologies"},
    {"name": "udiskie",                "env": "arch", "aur": False, "description": "Removable disk automounter using udisks"},
    {"name": "obsidian",               "env": "arch", "aur": False, "description": "A powerful knowledge base that works on top of a local folder of plain text Markdown files"},
    {"name": "docker",                 "env": "arch", "aur": False, "description": "Pack, ship and run any application as a lightweight container"},
    {"name": "docker-compose",         "env": "arch", "aur": False, "description": "Fast, isolated development environments using Docker"},
    {"name": "docker-buildx",          "env": "arch", "aur": False, "description": "Docker CLI plugin for extended build capabilities with BuildKit"},
    {"name": "telegram-desktop",       "env": "arch", "aur": False, "description": "Official Telegram Desktop client"},
    {"name": "file-roller",            "env": "arch", "aur": False, "description": "Create and modify archives"},
    {"name": "ocrdesktop",             "env": "arch", "aur": False, "description": "OCR the current window or desktop and make it browsable for the user"},
    {"name": "tesseract-data-eng",     "env": "arch", "aur": False, "description": "English language data files for the Tesseract OCR engine"},
    {"name": "playerctl",              "env": "arch", "aur": False, "description": "mpris media player controller and lib for spotify, vlc, audacious, bmp, xmms2, and others."},
    # ── Arch only ───────────────────────────────────────────────────────
    {"name": "vnstat",                 "env": "arch", "aur": False, "description": "A console-based network traffic monitor"},
    {"name": "ddcutil",                "env": "arch", "aur": False, "description": "Query and change Linux monitor settings using DDC/CI and USB."},
    {"name": "picom",                   "env": "arch", "aur": False ,  "description": "Lightweight compositor for X11"},
    {"name": "polybar",                 "env": "arch", "aur": False,  "description": "A fast and easy-to-use status bar"},
    {"name": "pacman-contrib",          "env": "arch", "aur": False,  "description": "Contributed scripts and tools for pacman systems"},
    {"name": "cava",                    "env": "arch", "aur": False,  "description": "Console-based Audio Visualizer with support for multiple backends"},
    {"name": "ttf-indic-otf",           "env": "arch", "aur": True,  "description": "Indic Opentype Fonts collection"},
    {"name": "i3-scrot",                "env": "arch", "aur": True,  "description": "simple screenshot script using scrot"},
    {"name": "ttf-poppins",             "env": "arch", "aur": True,  "description": "Poppins font by ITFoundry"},
    {"name": "apple-fonts",             "env": "arch", "aur": True,  "description": "Apple system fonts: SF Pro, SF Mono, NY, etc."},
    {"name": "ttf-font-awesome",        "env": "arch", "aur": True,  "description": "Icon font used widely in status bars and UIs"},
    {"name": "ttf-exo-2",               "env": "arch", "aur": True,  "description": "Exo 2 — contemporary geometric sans-serif font"},
    {"name": "noto-fonts-emoji",        "env": "arch", "aur": True,  "description": "Google Noto emoji font for full Unicode emoji coverage"},
    {"name": "pulseaudio-ctl",          "env": "arch", "aur": True,  "description": "CLI for controlling PulseAudio volume and mute from scripts"},
    {"name": "jmtpfs",                  "env": "arch", "aur": True,  "description": "FUSE filesystem for MTP devices using libmtp"},
    {"name": "apple_cursor",            "env": "arch", "aur": True,  "description": "macOS-style cursor theme for Linux"},
    {"name": "i3exit",                  "env": "arch", "aur": True,  "description": "Simple logout/power script for i3 window manager"},
    {"name": "visual-studio-code-bin",  "env": "arch", "aur": True,  "description": "Microsoft Visual Studio Code editor (official binary release)"},
    {"name": "x11-emoji-picker",        "env": "arch", "aur": True,  "description": "Emoji picker for X11 applications"},
    {"name": "ab-download-manager-bin", "env": "arch", "aur": True,  "description": "Fast download manager with browser integration"},
    {"name": "orchis-theme",            "env": "arch", "aur": True,  "description": "Material Design GTK theme with a clean, modern look"},
]
NPM_PACKAGES = [
    "pyright", "vim-language-server", "vscode-langservers-extracted",
    "typescript", "typescript-language-server", "emmet-ls",
    "bash-language-server", "yaml-language-server", "neovim",
    "biome", "prettier",
]
CARGO_PACKAGES = ["tree-sitter-cli"]
# ─────────────────────────────────────────────────────────────────────────────
# Description fetching
# ─────────────────────────────────────────────────────────────────────────────
_DESC_CACHE: dict[str, str] = {}
def _fetch_aur_descriptions(names: list[str]) -> dict[str, str]:
    """
    Batch-query the AUR RPC API for up to 250 packages at once.
    Returns {name: description}.
    """
    results: dict[str, str] = {}
    # AUR RPC supports multi-info with repeated 'arg[]=' params
    args = "&".join(f"arg[]={urllib.parse.quote(n)}" for n in names)
    url = f"https://aur.archlinux.org/rpc/v5/info?{args}"
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            data = json.loads(resp.read())
        for pkg in data.get("results", []):
            desc = pkg.get("Description") or ""
            results[pkg["Name"]] = desc
    except Exception:
        pass
    return results
def _fetch_pacman_description(name: str) -> str:
    """Run `pacman -Si <name>` and extract the Description field."""
    try:
        out = subprocess.run(
            f"pacman -Si {name}",
            shell=True, capture_output=True, text=True, timeout=8,
        ).stdout
        for line in out.splitlines():
            if line.lower().startswith("description"):
                return line.split(":", 1)[-1].strip()
    except Exception:
        pass
    return ""
def fetch_descriptions(packages: list[dict]) -> dict[str, str]:
    """
    Fetch descriptions for all packages concurrently.
    AUR packages → AUR RPC batch call.
    Pacman packages → parallel `pacman -Si` calls.
    Returns {name: description}.
    """
    aur_names = [p["name"] for p in packages if p["aur"]]
    pacman_names = [p["name"] for p in packages if not p["aur"]]
    desc: dict[str, str] = {}
    with console.status("[cyan] Fetching package descriptions…[/cyan]", spinner="dots"):
        # AUR: one batch HTTP call
        if aur_names:
            aur_desc = _fetch_aur_descriptions(aur_names)
            desc.update(aur_desc)
        # Pacman: parallel subprocesses (limit workers to avoid flooding)
        if pacman_names:
            with concurrent.futures.ThreadPoolExecutor(max_workers=16) as ex:
                futures = {ex.submit(_fetch_pacman_description, n): n
                           for n in pacman_names}
                for fut in concurrent.futures.as_completed(futures):
                    n = futures[fut]
                    desc[n] = fut.result()
    return desc
# ─────────────────────────────────────────────────────────────────────────────
# Interactive package selection with description table
# ─────────────────────────────────────────────────────────────────────────────
def _truncate(s: str, width: int) -> str:
    return s if len(s) <= width else s[:width - 1] + "…"
def select_packages_with_descriptions(
    packages: list[dict],
    has_yay: bool,
) -> list[str]:
    """
    Show an inquirer checkbox where every choice label is:
        package-name  [AUR]  — description
    The returned value for each choice is just the bare package name,
    so the rest of the install logic is unchanged.
    Returns list of selected package names.
    """
    ALL_LABEL = "ALL ⬇️  — install everything listed below"
    ALL_VALUE = "__ALL__"

    # Build (label, value) pairs — inquirer uses the label for display,
    # the value for what ends up in ans["sel"].
    choices = [(ALL_LABEL, ALL_VALUE)]
    for p in packages:
        src_tag = " [AUR]" if p["aur"] else ""
        if p["aur"] and not has_yay:
            src_tag = " [AUR↓pacman]"
        desc = p.get("description", "")
        label = f"{p['name']}{src_tag}"
        if desc:
            _DARK = "\033[38;5;240m"  # 256-colour dark grey — secondary text
            _RST  = "\033[0m"
            label += f"  {_DARK}—  {_truncate(desc, 60)}{_RST}"
        choices.append((label, p["name"]))

    ans = inquirer.prompt([inquirer.Checkbox(
        "sel",
        message="Select packages to install [SPACE = toggle · ENTER = confirm]",
        choices=choices,
    )])
    if not ans:
        return []
    sel = ans["sel"]
    names = [p["name"] for p in packages]
    return names if ALL_VALUE in sel else [s for s in sel if s != ALL_VALUE]
# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────
def run_silent(cmd: str) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, shell=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE)
def cmd_ok(cmd: str) -> bool:
    return run_silent(cmd).returncode == 0
def section(title: str):
    console.print()
    console.rule(f"[bold cyan]{title}[/bold cyan]")
def copy_config(src: str, dest: str):
    run_silent(f"mkdir -p {dest}")
    run_silent(f"yes | cp -rf {src} {dest}")
def checkbox_select(message: str, choices: list[str]) -> list[str]:
    """Simple checkbox — used for npm / cargo where descriptions aren't needed."""
    ALL = "ALL ⬇️"
    ans = inquirer.prompt([inquirer.Checkbox(
        "sel",
        message=f"{message} [SPACE = toggle · ENTER = confirm]",
        choices=[ALL, *choices],
    )])
    if not ans:
        return []
    sel = ans["sel"]
    return choices if ALL in sel else [p for p in sel if p != ALL]
# ─────────────────────────────────────────────────────────────────────────────
# Live-output installer
# ─────────────────────────────────────────────────────────────────────────────
def _stream_install(cmd: str) -> int:
    """Run cmd and stream stdout+stderr to the console in real-time."""
    proc = subprocess.Popen(
        cmd, shell=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, bufsize=1,
    )
    for line in proc.stdout:
        console.print(f" [dim]{line.rstrip()}[/dim]")
    proc.wait()
    return proc.returncode
def install_pkg(pkg: str, use_yay: bool) -> int:
    if use_yay and cmd_ok("yay --version"):
        cmd = f"yay -S {pkg} --noconfirm --needed"
    else:
        cmd = f"sudo pacman -S {pkg} --noconfirm --needed"
    return _stream_install(cmd)
def install_list_live(
    pkg_list: list[str],
    use_yay: bool,
    desc: dict[str, str],
    total_offset: int = 0,
    grand_total: int = 0,
) -> tuple[list[str], list[str]]:
    installed, failed = [], []
    total = grand_total or len(pkg_list)
    for i, pkg in enumerate(pkg_list, start=1 + total_offset):
        pkg_desc = desc.get(pkg, "")
        header = f"\n[bold white][{i}/{total}][/bold white] " \
                   f"[yellow]installing[/yellow] [bold]{pkg}[/bold]"
        if pkg_desc:
            header += f" [dim]— {_truncate(pkg_desc, 60)}[/dim]"
        console.print(header)
        rc = install_pkg(pkg, use_yay)
        if rc == 0:
            console.print(f" [bold green]✔ {pkg} — done[/bold green]")
            installed.append(pkg)
        else:
            console.print(f" [bold red]✘ {pkg} — failed (exit {rc})[/bold red]")
            failed.append(pkg)
    return installed, failed
def retry_failed(
    failed: list[str],
    use_yay: bool,
    label: str,
    desc: dict[str, str] | None = None,
) -> list[str]:
    while failed:
        console.print(f"\n[bold red] {len(failed)} {label} package(s) failed:[/bold red]")
        console.print(Columns(failed, equal=True, expand=True))
        ans = inquirer.prompt([inquirer.List(
            "retry", message=f"Retry failed {label} packages?",
            choices=["Yes", "No"],
        )])
        if not ans or ans["retry"] == "No":
            break
        _, failed = install_list_live(failed, use_yay, desc or {})
    return failed
def install_generic_live(pkg: str, cmd: str, i: int, total: int) -> bool:
    console.print(f"\n[bold white][{i}/{total}][/bold white] "
                  f"[yellow]installing[/yellow] [bold]{pkg}[/bold] …")
    rc = _stream_install(cmd)
    if rc == 0:
        console.print(f" [bold green]✔ {pkg} — done[/bold green]")
        return True
    console.print(f" [bold red]✘ {pkg} — failed (exit {rc})[/bold red]")
    return False
# ─────────────────────────────────────────────────────────────────────────────
# Ensure yay
# ─────────────────────────────────────────────────────────────────────────────
def ensure_yay() -> bool:
    if cmd_ok("yay --version"):
        rprint("[bold green]✔ yay already installed[/bold green]")
        return True
    rprint("[yellow] yay not found — building from AUR…[/yellow]")
    _stream_install("sudo pacman -S --needed base-devel git --noconfirm")
    _stream_install(
        "cd ~ && git clone https://aur.archlinux.org/yay.git"
        " && cd ~/yay && makepkg -si --noconfirm"
        " && cd ~ && rm -rf yay"
    )
    return cmd_ok("yay --version")
# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
def main():
    subprocess.run("clear", shell=True)
    console.print(Panel.fit(
        "[bold cyan]Dotfiles Installer[/bold cyan]\n"
        "[dim]Arch · WSL · yay + pacman · live output · package descriptions[/dim]",
        border_style="cyan",
    ))
    # ── 1. Auto-detect / confirm environment ──────────────────────────────────
    section("Environment Detection")
    detected = detect_env()
    label_map = {"wsl": "WSL (Windows Subsystem for Linux)", "arch": "Arch Linux"}
    rprint(f" Detected: [bold green]{label_map[detected]}[/bold green]")
    confirm = inquirer.prompt([inquirer.List(
        "env",
        message=f"Continue as {detected.upper()}? (or switch)",
        choices=[detected.upper(), "WSL" if detected == "arch" else "ARCH"],
    )])
    env = (confirm["env"].lower() if confirm else detected)
    rprint(f" Using environment: [bold cyan]{env.upper()}[/bold cyan]")
    # ── 2. System update ──────────────────────────────────────────────────────
    section("System Update — pacman -Syu")
    _stream_install("sudo pacman -Syu --noconfirm")
    # ── 3. Ensure yay ─────────────────────────────────────────────────────────
    section("AUR Helper — yay")
    has_yay = ensure_yay()
    # ── 4. Package selection with descriptions ────────────────────────────────
    section("Package Selection")
    eligible = [p for p in PACKAGES if p["env"] in (env, "both")]
    # Build description lookup from hardcoded values — no network calls needed.
    all_desc = {p["name"]: p.get("description", "") for p in eligible}
    selected = select_packages_with_descriptions(eligible, has_yay)
    if selected:
        meta = {p["name"]: p for p in eligible}
        pacman_sel = [n for n in selected if not meta[n]["aur"]]
        aur_sel = [n for n in selected if meta[n]["aur"]]
        all_failed: list[str] = []
        offset = 0
        grand = len(selected)
        if pacman_sel:
            section(f"Installing pacman packages ({len(pacman_sel)} / {grand})")
            _, failed = install_list_live(
                pacman_sel, False, all_desc,
                total_offset=offset, grand_total=grand,
            )
            offset += len(pacman_sel)
            all_failed += retry_failed(failed, False, "pacman", all_desc)
        if aur_sel:
            section(f"Installing AUR packages ({len(aur_sel)} / {grand})")
            _, failed = install_list_live(
                aur_sel, has_yay, all_desc,
                total_offset=offset, grand_total=grand,
            )
            offset += len(aur_sel)
            all_failed += retry_failed(failed, has_yay, "AUR", all_desc)
        if all_failed:
            console.print(f"\n[bold red]Packages that could not be installed:[/bold red]")
            console.print(Columns(all_failed, equal=True, expand=True))
    else:
        rprint("[dim] No packages selected.[/dim]")
    # ── 5. npm ────────────────────────────────────────────────────────────────
    section("npm packages")
    if cmd_ok("npm --version"):
        run_silent("mkdir -p ~/.npm && npm config set prefix ~/.npm")
        npm_sel = checkbox_select("Select npm packages to install", NPM_PACKAGES)
        if npm_sel:
            npm_failed = []
            for i, pkg in enumerate(npm_sel, 1):
                if not install_generic_live(pkg, f"npm install -g {pkg}", i, len(npm_sel)):
                    npm_failed.append(pkg)
            retry_failed(npm_failed, False, "npm")
    else:
        rprint("[red] npm not found — skipping.[/red]")
    # ── 6. cargo ──────────────────────────────────────────────────────────────
    section("Cargo packages")
    if cmd_ok("cargo version") or cmd_ok("rustup --version"):
        run_silent("rustup default stable")
        cargo_sel = checkbox_select("Select cargo packages to install", CARGO_PACKAGES)
        if cargo_sel:
            cargo_failed = []
            for i, pkg in enumerate(cargo_sel, 1):
                if not install_generic_live(pkg, f"cargo install --locked {pkg}", i, len(cargo_sel)):
                    cargo_failed.append(pkg)
            retry_failed(cargo_failed, False, "cargo")
    else:
        rprint("[red] cargo/rustup not found — skipping.[/red]")
    # ── 7. ZSH / oh-my-zsh ───────────────────────────────────────────────────
    section("ZSH & oh-my-zsh")
    ans = inquirer.prompt([inquirer.List(
        "zsh", message="Install oh-my-zsh and ZSH config?", choices=["Yes", "No"],
    )])
    if ans and ans["zsh"] == "Yes":
        _stream_install('sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"')
        _stream_install("git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting")
        _stream_install("git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions")
        _stream_install("git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install")
        run_silent("chsh -s $(which zsh)")
        if cmd_ok("starship --version"):
            copy_config(f"{DOTFILES}/.config/starship.toml", "~/.config/")
        run_silent(f"yes | cp -rf {DOTFILES}/.zshrc ~/")
        run_silent(f"yes | cp -rf {DOTFILES}/.zshenv ~/")
        rprint("[dim] .zshrc / .zshenv copied. Restart shell to apply.[/dim]")
    # ── 8. Neovim ─────────────────────────────────────────────────────────────
    section("Neovim config")
    if cmd_ok("nvim --version"):
        ans = inquirer.prompt([inquirer.List(
            "nvim", message="Install Neovim config?", choices=["Yes", "No"],
        )])
        if ans and ans["nvim"] == "Yes":
            _stream_install('sh -c \'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim\'')
            copy_config(f"{DOTFILES}/.config/nvim/*", "~/.config/nvim/")
            rprint("[cyan] Running PlugInstall…[/cyan]")
            subprocess.run('nvim +"PlugInstall --sync" +qa', shell=True)
    else:
        rprint("[red] nvim not installed.[/red]")
    # ── 9. Yazi ───────────────────────────────────────────────────────────────
    section("Yazi config")
    if cmd_ok("yazi --version"):
        ans = inquirer.prompt([inquirer.List(
            "yazi", message="Install Yazi config?", choices=["Yes", "No"],
        )])
        if ans and ans["yazi"] == "Yes":
            copy_config(f"{DOTFILES}/.config/yazi/*", "~/.config/yazi/")
            _stream_install(
                "cd ~/.config/yazi/ && ya pkg add "
                "yazi-rs/plugins:full-border imsi32/yatline MasouShizuka/projects "
                "DreamMaoMao/fg AnirudhG07/plugins-yazi:copy-file-contents "
                "Lil-Dank/lazygit pirafrank/what-size"
            )
    else:
        rprint("[red] yazi not installed.[/red]")
    # ── 10. Newsboat ──────────────────────────────────────────────────────────
    section("Newsboat config")
    if cmd_ok("newsboat --version"):
        ans = inquirer.prompt([inquirer.List(
            "nb", message="Install Newsboat config?", choices=["Yes", "No"],
        )])
        if ans and ans["nb"] == "Yes":
            copy_config(f"{DOTFILES}/.config/newsboat/*", "~/.config/newsboat/")
    else:
        rprint("[red] newsboat not installed.[/red]")
    # ── 11. tmux ──────────────────────────────────────────────────────────────
    section("tmux config")
    if cmd_ok("tmux -V"):
        ans = inquirer.prompt([inquirer.List(
            "tmux", message="Install tmux config?", choices=["Yes", "No"],
        )])
        if ans and ans["tmux"] == "Yes":
            copy_config(f"{DOTFILES}/.config/tmux", "~/.config/")
            _stream_install("git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm")
    else:
        rprint("[red] tmux not installed.[/red]")
    # ── 12. GitHub CLI ────────────────────────────────────────────────────────
    section("GitHub CLI")
    if cmd_ok("gh --version"):
        ans = inquirer.prompt([inquirer.List(
            "gh", message="Authenticate GitHub CLI?", choices=["Yes", "No"],
        )])
        if ans and ans["gh"] == "Yes":
            run_silent("sudo systemctl start sshd.service && sudo systemctl enable sshd.service")
            subprocess.run("gh auth login", shell=True)
    else:
        rprint("[red] gh not installed.[/red]")
    # ── 13. Arch-only configs ─────────────────────────────────────────────────
    if env == "arch":
        def ask(key: str, msg: str) -> bool:
            a = inquirer.prompt([inquirer.List(key, message=msg, choices=["Yes", "No"])])
            return bool(a and a[key] == "Yes")
        def config_if_installed(check_cmd, name, key, src, dest):
            section(name)
            if cmd_ok(check_cmd):
                if ask(key, f"Install {name} config?"):
                    copy_config(src, dest)
            else:
                rprint(f"[red] {name} not installed.[/red]")
        section("Fonts, Keyboard & Power")
        if ask("font", "Install font, keyboard & power configs?"):
            run_silent(f"sudo cp {DOTFILES}/etc/local.conf /etc/fonts/local.conf")
            run_silent(f"sudo cp {DOTFILES}/etc/00-keyboard.conf /etc/X11/xorg.conf.d/")
            run_silent(f"sudo cp {DOTFILES}/etc/logind.conf /etc/systemd/logind.conf")
            run_silent(f"mkdir -p $HOME/.fonts && yes | cp -rf {DOTFILES}/.fonts/* $HOME/.fonts/")
            _stream_install("fc-cache -fv")
        config_if_installed("kitty --version", "Kitty", "kitty",
                            f"{DOTFILES}/.config/kitty/*", "~/.config/kitty/")
        config_if_installed("zathura --version", "Zathura", "zathura",
                            f"{DOTFILES}/.config/zathura/*", "~/.config/zathura/")
        section("mpv")
        if cmd_ok("mpv --version"):
            if ask("mpv", "Install mpv config?"):
                copy_config(f"{DOTFILES}/.config/mpv/*", "~/.config/mpv/")
                run_silent(f"yes | cp -rf {DOTFILES}/.xbindkeysrc ~/")
        else:
            rprint("[red] mpv not installed.[/red]")
        section("GTK 3")
        if ask("gtk", "Install GTK 3 config?"):
            copy_config(f"{DOTFILES}/.config/gtk-3.0", "~/.config/")
            run_silent(f"yes | cp -rf {DOTFILES}/.config/mimeapps.list ~/.config/")
        config_if_installed("i3 --version", "i3", "i3",
                            f"{DOTFILES}/.config/i3", "~/.config/")
        if cmd_ok("i3 --version") and ask("xres", "Copy .Xresources?"):
            run_silent(f"yes | cp -rf {DOTFILES}/.Xresources ~/")
        config_if_installed("picom --version", "Picom", "picom",
                            f"{DOTFILES}/.config/picom.conf", "~/.config/")
        config_if_installed("rofi -v", "Rofi", "rofi",
                            f"{DOTFILES}/.config/rofi", "~/.config/")
        section("Polybar")
        if cmd_ok("polybar -v"):
            if ask("poly", "Install polybar config?"):
                copy_config(f"{DOTFILES}/.config/polybar", "~/.config/")
                run_silent("chmod +xwr ~/.config/polybar/scripts/*.sh")
                _stream_install("sudo systemctl enable --now vnstat")
        else:
            rprint("[red] polybar not installed.[/red]")
        config_if_installed("dunst -v", "Dunst", "dunst",
                            f"{DOTFILES}/.config/dunst", "~/.config/")
        config_if_installed("conky -v", "Conky", "conky",
                            f"{DOTFILES}/.config/conky", "~/.config/")
        config_if_installed("imwheel -v", "Imwheel", "imwheel",
                            f"{DOTFILES}/.imwheelrc", "~/")
        section("Scrot")
        if cmd_ok("scrot -v"):
            if ask("scrot", "Create screenshots directory?"):
                run_silent("mkdir -p $HOME/.screenshots")
        section("Docker")
        if cmd_ok("sudo docker --version"):
            if ask("docker", "Configure Docker (no-sudo)?"):
                _stream_install("sudo groupadd -f docker && sudo usermod -aG docker $(whoami) && newgrp docker")
        else:
            rprint("[red] docker not installed.[/red]")
        section("pacman.conf")
        if ask("pac", "Enable Color & ParallelDownloads in pacman.conf?"):
            run_silent("sudo sed -i -e 's/^#Color/Color/g' /etc/pacman.conf")
            run_silent("sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads=5/g' /etc/pacman.conf")
        section("Apple Cursor")
        if ask("cur", "Install macOS Monterey cursor?"):
            _stream_install(
                "mkdir -p ~/.icons && cd ~/.icons"
                " && wget https://github.com/ful1e5/apple_cursor/releases/latest/download/macOSMonterey.tar.gz"
                " && tar xvf macOSMonterey.tar.gz && rm macOSMonterey.tar.gz"
            )
            copy_config(f"{DOTFILES}/.config/gtk-3.0/*", "~/.config/gtk-3.0/")
    # ── Done ──────────────────────────────────────────────────────────────────
    console.print()
    console.print(Panel.fit(
        "[bold green]✔ Installation complete![/bold green]\n"
        "[dim]Restart your shell (or log out/in) to apply all changes.[/dim]",
        border_style="green",
    ))
if __name__ == "__main__":
    main()
