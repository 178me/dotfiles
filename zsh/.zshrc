# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/yzl178me/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
# ZSH_THEME="arrow"
ZSH_THEME="awesomepanda"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
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
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# 加载 complete 目前解决asdf 插件的一个bug
autoload bashcompinit && bashcompinit
# autoload -U +X bashcompinit && bashcompinit
plugins=(git extract zsh-syntax-highlighting zsh-autosuggestions git-open sudo asdf autojump)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias
alias c='clear'
alias v='nvim'
alias Rr='shutdown -r now'
alias r='ranger'
alias off='shutdown now'
alias vi3='nvim ~/.config/i3/config'
alias vzsh='nvim ~/.zshrc'
alias aa='sudo pacman -S'
alias as='pacman -Ss'
alias au='sudo pacman -Syyu'
alias ar='sudo pacman -R'
alias ys='yay -Ss'
alias zj='neofetch'
alias pc='export https_proxy="127.0.0.1:12333";export http_proxy="127.0.0.1:12333"'
alias dpc='unset https_proxy http_proxy;export -p'
alias pylupdate5='/home/yzl178me/.local/bin/pylupdate5'
alias pyrcc5='/home/yzl178me/.local/bin/pyrcc5'
alias pyuic5='/home/yzl178me/.local/bin/pyuic5'
alias ax="aria2c -x16"
alias ae="aria2c -x16 -enable-rpc"
alias lzc="lzc-cli"
alias lzcD="lzc-cli project devshell --log debug -r"
alias lzcB="lzc-cli project build -f"
alias lzcP="lzc-cli appstore publish"
alias lzcS="ssh root@188me.heiyu.space"
alias lg="lazygit"
alias llu="python /home/yzl178me/Myfile/update_all.py"
alias vme="python ~/dotfiles/script/switch_nvim.py 178me ;nvim"
alias vla="python ~/dotfiles/script/switch_nvim.py lazy ;nvim"
alias adbbb="python ~/dotfiles/script/adb_connect.py"
# ranger
export RANGER_LOAD_DEFAULT_RC=FALSE
export ANDROID_HOME=/home/yzl178me/Android/Sdk
export ANDROID_SDK_ROOT=/home/yzl178me/Android/Sdk
export PATH=/home/yzl178me/.local/bin:$PATH
export PATH=/home/yzl178me/go/bin:$PATH
export PATH=/home/yzl178me/Android/Sdk/cmdline-tools/bin:$PATH
xset r rate 200 65
