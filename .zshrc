# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.local/bin:/.local/lib:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin/:$HOME/.npm/bin:$HOME/bin:$PYENV_ROOT/bin:$PATH"
export PATH="`ruby -e 'puts Gem.user_dir'`/bin:$PATH"
export ADW_DISABLE_PORTAL=1
export TESSDATA_PREFIX=/usr/share/tessdata/

export PATH=/home/rodd/.opencode/bin:$PATH

# bun completions
[ -s "/home/rodd/.bun/_bun" ] && source "/home/rodd/.bun/_bun"

# Brew
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git
    node
    npm
    brew
    pip
    python
    extract
    zsh-syntax-highlighting
    zsh-autosuggestions
    colored-man-pages
    cp
    torrent
    z
    themes
    colorize
    web-search
    # vi-mode
    transfer
    safe-paste
    scd
    history-substring-search
    command-not-found
    colorize
)

export TLDR_HEADER='magenta bold underline'
export TLDR_QUOTE='italic'
export TLDR_DESCRIPTION='green'
export TLDR_CODE='red'
export TLDR_PARAM='blue'

source $ZSH/oh-my-zsh.sh

# User configuration

# Show directory without background color 
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias ls='lsd --group-dirs=first'
alias la='lsd -a'
alias lla='lsd -la'
alias lcg='lsd --gs'
alias cl='clear'
alias cp='cp -i' #Confirm before overwriting
alias aria='aria2c -x16 -c -k1M -j10 -m16'

alias rmx='trash put'
alias rme='trash empty'
alias rml='trash list'
alias rmr='trash restore'
alias rmra='trash restore --all'
alias rmea='trash empty --all'
alias yt='yt-dlp -f "bestvideo[height=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4 --add-chapters -c'
alias ytcookie='yt-dlp --cookies-from-browser chrome -f "bestvideo[height=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4 --add-chapters -c'
alias lg='lazygit'


# Eza
alias l="eza -l --icons --git -a"
alias ll="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# 7z
alias 7zCompress='7z a -t7z -md=16m'
alias 7zExtract='7z x -o./'

# Automatically activate or deactivate Python virtualenv in a directory
function cd() {
  builtin cd "$@" || return  # Always fail fast if cd fails

  # If no virtual environment is currently active
  if [[ -z "$VIRTUAL_ENV" ]]; then
    # Check for a local virtual environment folder
    if [[ -d "./.venv/bin" ]]; then
      source "./.venv/bin/activate"
    fi
  else
    # A virtual environment is active, check if we are still inside it
    parentdir="$(dirname "$VIRTUAL_ENV")"
    # If the current directory is no longer under the parent of the venv, deactivate
    if [[ "${PWD}" != "$parentdir"* ]]; then
      # Only call deactivate if it's defined
      if declare -f deactivate >/dev/null 2>&1; then
        deactivate
      fi
    fi
  fi
}



# use y instead of yazi to start, and press q to quit, you'll see the CWD changed
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}


syncnvim() {
  if [ -z "$1" ]; then
    echo "Usage: syncnvim \"commit message\""
    return 1
  fi

  local COMMIT_MSG="$1"
  local NVIM_SOURCE="$HOME/.config/nvim"
  local NVIM_DEST="$HOME/github/dot-files/.config/nvim"
  local LOCKFILE="$NVIM_DEST/lazy-lock.json"
  local DOTFILES_REPO="$HOME/github/dot-files"

  echo "Removing existing $NVIM_DEST..."
  sudo rm -rf "$NVIM_DEST"

  echo "Copying $NVIM_SOURCE to $NVIM_DEST..."
  mkdir -p "$(dirname "$NVIM_DEST")"
  sudo cp -r "$NVIM_SOURCE" "$NVIM_DEST"

  if [ -f "$LOCKFILE" ]; then
    echo "Removing lock file $LOCKFILE..."
    sudo rm "$LOCKFILE"
  fi

  cd "$DOTFILES_REPO" || {
    echo "Failed to cd into $DOTFILES_REPO"
    return 1
  }

  echo "Adding and committing changes..."
  git add .config/nvim
  git commit -m "$COMMIT_MSG"
  git push

  echo "✅ syncnvim complete!"
}

# Comprehensive Arch Linux cleanup function
cleanup_arch() {
    echo "🧹 Starting Arch Linux cleanup..."
    
    # Color codes for better output
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color
    
    # Function to print colored output
    print_status() {
        echo -e "${GREEN}[INFO]${NC} $1"
    }
    
    print_warning() {
        echo -e "${YELLOW}[WARNING]${NC} $1"
    }
    
    print_error() {
        echo -e "${RED}[ERROR]${NC} $1"
    }
    
    # Check if running as root (not recommended)
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. This is not recommended for regular cleanup."
    fi
    
    # 1. Clean pacman cache
    print_status "Cleaning pacman cache..."
    if command -v pacman &> /dev/null; then
        # Keep only the most recent version of each package
        sudo pacman -Sc --noconfirm
        
        # Optional: Uncomment the next line to remove ALL cached packages
        # sudo pacman -Scc --noconfirm
        
        # Clean orphaned packages
        print_status "Removing orphaned packages..."
        local orphans=$(pacman -Qtdq 2>/dev/null)
        if [[ -n "$orphans" ]]; then
            sudo pacman -Rns $orphans --noconfirm
            print_status "Removed orphaned packages: $orphans"
        else
            print_status "No orphaned packages found"
        fi
    else
        print_error "Pacman not found"
    fi
    
    # 2. Clean paru cache (if installed)
    if command -v paru &> /dev/null; then
        print_status "Cleaning paru cache..."
        paru -Sc --noconfirm
        
        # Clean paru build directory
        if [[ -d ~/.cache/paru ]]; then
            print_status "Cleaning paru build cache..."
            rm -rf ~/.cache/paru/clone/*
        fi
    else
        print_status "Paru not installed, skipping paru cleanup"
    fi
    
    # 3. Clean yay cache (if installed)
    if command -v yay &> /dev/null; then
        print_status "Cleaning yay cache..."
        yay -Sc --noconfirm
        
        # Clean yay build directory
        if [[ -d ~/.cache/yay ]]; then
            print_status "Cleaning yay build cache..."
            rm -rf ~/.cache/yay/*
        fi
    else
        print_status "Yay not installed, skipping yay cleanup"
    fi
    
    # 4. Clean temporary files
    print_status "Cleaning temporary files..."
    
    # System temp directories (requires sudo)
    if [[ -w /tmp ]]; then
        find /tmp -type f -atime +7 -delete 2>/dev/null || true
        find /tmp -type d -empty -delete 2>/dev/null || true
    fi
    
    # User temp directories
    [[ -d ~/.cache ]] && find ~/.cache -type f -atime +30 -delete 2>/dev/null || true
    [[ -d ~/.tmp ]] && rm -rf ~/.tmp/* 2>/dev/null || true
    
    # 5. Clean systemd journal logs
    print_status "Cleaning systemd journal logs..."
    sudo journalctl --disk-usage
    # Keep only last 2 weeks of logs
    sudo journalctl --vacuum-time=2weeks
    
    # 6. Clean thumbnails
    print_status "Cleaning thumbnails..."
    [[ -d ~/.cache/thumbnails ]] && rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
    [[ -d ~/.thumbnails ]] && rm -rf ~/.thumbnails/* 2>/dev/null || true
    
    # 7. Clean browser caches (optional - be careful with this)
    if [[ "$1" == "--deep" ]]; then
        print_warning "Deep cleaning browser caches (--deep flag detected)..."
        
        # Firefox
        [[ -d ~/.cache/mozilla ]] && rm -rf ~/.cache/mozilla/* 2>/dev/null || true
        
        # Chrome/Chromium
        [[ -d ~/.cache/google-chrome ]] && rm -rf ~/.cache/google-chrome/* 2>/dev/null || true
        [[ -d ~/.cache/chromium ]] && rm -rf ~/.cache/chromium/* 2>/dev/null || true
    fi
    
    # 8. Clean old log files
    print_status "Cleaning old log files..."
    find ~/.local/share/xorg -name "*.log" -mtime +30 -delete 2>/dev/null || true
    
    # 9. Clean pip cache
    if command -v pip &> /dev/null; then
        print_status "Cleaning pip cache..."
        pip cache purge 2>/dev/null || true
    fi
    
    # 10. Clean npm cache
    if command -v npm &> /dev/null; then
        print_status "Cleaning npm cache..."
        npm cache clean --force 2>/dev/null || true
    fi
    
    # 11. Clean cargo cache
    if command -v cargo &> /dev/null && [[ -d ~/.cargo ]]; then
        print_status "Cleaning cargo cache..."
        [[ -d ~/.cargo/registry/cache ]] && rm -rf ~/.cargo/registry/cache/* 2>/dev/null || true
    fi
    
    # 12. Show disk space saved
    print_status "Cleanup completed!"
    echo -e "${GREEN}💾 Current disk usage:${NC}"
    df -h / | tail -1
    
    # Optional: Show largest directories in home
    if [[ "$1" == "--analyze" ]]; then
        echo -e "\n${YELLOW}📊 Largest directories in your home:${NC}"
        du -ah ~ | sort -rh | head -10
    fi
}

# Add an alias for quick access
alias cleanup='cleanup_arch'
alias cleanup-deep='cleanup_arch --deep'
alias cleanup-analyze='cleanup_arch --analyze'

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/smr/.dart-cli-completion/zsh-config.zsh ]] && . /home/smr/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]


# opencode
export PATH=/home/smr/.opencode/bin:$PATH
