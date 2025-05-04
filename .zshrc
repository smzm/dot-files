# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.local/bin:/.local/lib:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin/:$HOME/.npm/bin:$HOME/bin:$PYENV_ROOT/bin:$PATH"
export PATH="`ruby -e 'puts Gem.user_dir'`/bin:$PATH"

export TESSDATA_PREFIX=/usr/share/tessdata/

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

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

cs(){
   cheat_directory="$HOME/cheatsheets"  # <=========== CHANGE THIS IF NEEDED
   if [ -d $cheat_directory ]; then
       $cheat_directory/wikiScript.sh
   else
       echo "Please clone cheatsheets repository in $HOME"
       echo "      https -->   git clone https://github.com/smzm/cheatsheets.git" 
       echo "      ssh   -->   ssh git@github.com:smzm/cheatsheets.git"
       
   fi
}

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


# Enable and disable venv in python dierctory automatically
function cd() {
  builtin cd "$@"

  if [[ -z "$VIRTUAL_ENV" ]] ; then
    ## If env folder is found then activate the vitualenv
      if [[ -d ./.venv ]] ; then
        source ./.venv/bin/activate
      fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
      parentdir="$(dirname "$VIRTUAL_ENV")"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        deactivate
      fi
  fi
}

export GROQ_API_KEY="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"
