# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.local/bin:/.local/lib:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin/:$HOME/.npm/bin:$HOME/bin:$PYENV_ROOT/bin:$PATH"
export PATH="`ruby -e 'puts Gem.user_dir'`/bin:$PATH"

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



