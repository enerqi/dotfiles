# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="enerqi"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git git-extras cabal colorize zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
export PATH="$PATH:/opt/perforce/p4/bin"
export PATH="$HOME/.cabal/bin:$PATH"
export PATH="$PATH:$HOME/bin"
typeset -U PATH

# git-extras install: (cd /tmp && git clone --depth 1 https://github.com/visionmedia/git-extras.git && cd git-extras && sudo make install)

# oh-my-zsh/lib/grep.zsh assumes grep >= 2.5.3. FreeBSD 10 = 2.5.1. gnugrep=2.18 installed to /usr/local/bin
[[ `uname` = FreeBSD ]] && alias grep='/usr/local/bin/grep'

alias c=colorize_via_pygmentize
alias hadoop='nocorrect hadoop'
alias hi='rlwrap --always-readline -t dumb hive'
alias hl='hdfs dfs -ls'
alias xclip='xclip -selection c'

# zsh-syntax-highlighting plugin - default is just "main" highlighter
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main) # brackets pattern root)


function cl() {
    FILENAMES=("$@")

    colorize $FILENAMES | less
}

function git_permission_reset() {
    git diff -p -R | grep -E "^(diff|(old|new) mode)" | git apply
}

# ghc-pkg-reset
# Removes all installed GHC/cabal packages, but not binaries, docs, etc.
# Use this to get out of dependency hell and start over, at the cost of some rebuilding time.
function ghc-pkg-reset() {
    # bash: read -p 'erasing all your user ghc and cabal packages - are you sure (y/n) ? ' ans
    read -q "ans?Erasing all your user ghc and cabal packages - are you sure (y/n) ?"
    [[ $ans == 'y' ]] && ( \
        echo 'erasing directories under ~/.ghc'; rm -rf `find ~/.ghc -maxdepth 1 -type d`; \
        echo 'erasing ~/.cabal/lib'; rm -rf ~/.cabal/lib; \
        echo 'erasing ~/.cabal/packages'; rm -rf ~/.cabal/packages; \
        echo 'erasing ~/.cabal/share'; rm -rf ~/.cabal/share; \
        )
}


# Local machine specific shell setup that we don't want to commit to source control
if [[ -f ~/.rc.local ]]; then
    source ~/.rc.local
fi
