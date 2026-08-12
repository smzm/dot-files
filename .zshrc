# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================
# Oh My Zsh
# ============================================================

export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="robbyrussell"

plugins=(
    git
    brew
    extract
    z
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    history-substring-search
    command-not-found
)

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

source "$ZSH/oh-my-zsh.sh"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================
# Environment
# ============================================================

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"


# ============================================================
# PATH
# ============================================================

export PATH="/usr/local/cuda/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.cargo/bin:$HOME/bin:$HOME/.opencode/bin:$HOME/.lmstudio/bin:$PATH"


# ============================================================
# Homebrew
# ============================================================

if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi


# ============================================================
# Pyenv
# ============================================================

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi


# ============================================================
# FNM - Fast Node Manager
# ============================================================

if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd)"
fi


# ============================================================
# Bun
# ============================================================

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"


# ============================================================
# FZF
# ============================================================

[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"


# ============================================================
# Aliases
# ============================================================

# General
alias cl='clear'
alias cp='cp -i'

# Eza
alias ls='eza --group-directories-first'
alias la='eza -a --group-directories-first'
alias lla='eza -la --group-directories-first'

alias l='eza --tree --level=1 --icons --git --group-directories-first'
alias ll='eza --tree --level=2 --icons --git --group-directories-first'
alias lx='eza --tree --level=1 --long --icons --git --group-directories-first'
alias llx='eza --tree --level=2 --long --icons --git --group-directories-first'

# Git / Docker
alias lg='lazygit'
alias ld='lazydocker'

# Downloads
alias aria='aria2c -x16 -c -k1M -j10 -m16'

alias ytdownload='yt-dlp \
    --newline \
    --ignore-config \
    --no-playlist \
    --embed-subs \
    --embed-chapters \
    --embed-metadata \
    --embed-thumbnail \
    -o "%(title).200s.%(ext)s"'


# ============================================================
# 7-Zip
# ============================================================

alias encrypt7z='7z a -t7z -mx=9 -mhe=on -p'
alias extract7z='7z x'


# ============================================================
# Tmux
# ============================================================

alias tmux='tmux new-session -A -s 0'


# ============================================================
# Python Virtual Environment
# ============================================================

# Automatically activate/deactivate a local .venv.
#
# Note:
# uv normally handles project environments itself, so this is
# mainly useful when working with traditional .venv projects.

function cd() {
    builtin cd "$@" || return

    # No virtual environment currently active
    if [[ -z "$VIRTUAL_ENV" ]]; then

        # Activate local .venv if it exists
        if [[ -d "./.venv/bin" ]]; then
            source "./.venv/bin/activate"
        fi

    else
        # Directory containing the active virtual environment
        local parentdir
        parentdir="$(dirname "$VIRTUAL_ENV")"

        # Deactivate when leaving the project directory
        if [[ "${PWD}" != "$parentdir"* ]]; then

            if (( $+functions[deactivate] )); then
                deactivate
            fi

        fi
    fi
}


# ============================================================
# Yazi
# ============================================================

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    local cwd

    yazi "$@" --cwd-file="$tmp"

    IFS= read -r -d '' cwd < "$tmp"

    if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
        builtin cd -- "$cwd"
    fi

    rm -f -- "$tmp"
}


# ============================================================
# Neovim Dotfiles Synchronization
# ============================================================

function syncnvim() {
    if [[ -z "$1" ]]; then
        echo 'Usage: syncnvim "commit message"'
        return 1
    fi

    local COMMIT_MSG="$1"
    local NVIM_SOURCE="$HOME/.config/nvim"
    local NVIM_DEST="$HOME/dot-files/.config/nvim"
    local LOCKFILE="$NVIM_DEST/lazy-lock.json"
    local DOTFILES_REPO="$HOME/dot-files"

    echo "Removing existing $NVIM_DEST..."
    rm -rf "$NVIM_DEST"

    echo "Copying $NVIM_SOURCE to $NVIM_DEST..."
    mkdir -p "$(dirname "$NVIM_DEST")"
    cp -r "$NVIM_SOURCE" "$NVIM_DEST"

    if [[ -f "$LOCKFILE" ]]; then
        echo "Removing lock file $LOCKFILE..."
        rm "$LOCKFILE"
    fi

    builtin cd "$DOTFILES_REPO" || {
        echo "Failed to cd into $DOTFILES_REPO"
        return 1
    }

    echo "Adding and committing changes..."

    git add .config/nvim

    git commit -m "$COMMIT_MSG" || {
        echo "Commit failed."
        return 1
    }

    git push || {
        echo "Push failed."
        return 1
    }

    echo "syncnvim complete!"
}


# ============================================================
# Monitor Brightness
# ============================================================

function brightness-set() {
    local val="$1"

    if [[ "$val" =~ ^[0-9]+$ ]] && (( val >= 0 && val <= 100 )); then
        ddcutil setvcp 10 "$val" --noverify
    else
        echo "Usage: brightness-set <0-100>"
        return 1
    fi
}

function brightness-status() {
    ddcutil getvcp 10
}

function brightness-reset() {
    ddcutil setvcp 04 1
}


# ============================================================
# Monitor Contrast
# ============================================================

function contrast-set() {
    local val="$1"

    if [[ "$val" =~ ^[0-9]+$ ]] && (( val >= 0 && val <= 100 )); then
        ddcutil setvcp 12 "$val" --noverify
    else
        echo "Usage: contrast-set <0-100>"
        return 1
    fi
}

function contrast-status() {
    ddcutil getvcp 12
}

function contrast-reset() {
    ddcutil setvcp 05 1
}


# ============================================================
# Whisper.cpp Transcription
# ============================================================

# Requirements:
#   whisper.cpp-cuda
#
# Model:
#   ~/.local/share/whisper.cpp/models/ggml-large-v3-turbo.bin

function transcribe() {
    local video="$1"

    if [[ -z "$video" || ! -f "$video" ]]; then
        echo "Usage: transcribe <video-file>"
        return 1
    fi

    local dir="${video:h}"
    local base="${video:t:r}"

    # Convert audio to WAV
    ffmpeg -i "$video" \
        -ar 16000 \
        -ac 1 \
        -c:a pcm_s16le \
        "$dir/$base.wav" || return 1

    # Transcribe with Whisper CUDA
    whisper-cli \
        -m "$HOME/.local/share/whisper.cpp/models/ggml-large-v3-turbo.bin" \
        -f "$dir/$base.wav" \
        -otxt \
        -of "$dir/$base" || return 1

    # Remove temporary WAV
    rm -f "$dir/$base.wav"
}


