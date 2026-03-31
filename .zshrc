# profile start:
# zmodload zsh/zprof

# load [zgenom plugin manager](https://github.com/jandamm/zgenom), successor to and compatible with zgen
source "${HOME}/.zgenom/zgenom.zsh"

# Checks for plugin and zgenom updates every 7 days
# This does not increase the startup time.
zgenom autoupdate

# auto run `zgenom reset` when changes detected to these files
ZGEN_RESET_ON_CHANGE=($HOME/.zshrc $HOME/.zshrc.local)

# Everything in this if branch is loaded pre-compiled from an init script if it exists
# if the init script doesn't exist (use `zgenom reset` to clear the init script) then run all
# these (slow) zgenom functions
if ! zgenom saved; then
    echo "Creating a zgenom save"

    # Ohmyzsh base library --- now likely redundant given later tools
    # zgenom ohmyzsh
    # plugins
    # mise is loaded lazily with the mise() function further below
    # zgenom ohmyzsh plugins/mise
    # zgenom ohmyzsh plugins/git
    # zgenom ohmyzsh plugins/sudo
    # just load the completions
    # zgenom ohmyzsh --completion plugins/docker-compose

    # Prezto core (keep these — they are lightweight and provide good defaults)
    # If you use prezto and ohmyzsh - load ohmyzsh first.
    zgenom prezto
    zgenom prezto environment
    zgenom prezto terminal
    zgenom prezto editor
    zgenom prezto history
    zgenom prezto directory
    zgenom prezto spectrum
    zgenom prezto utility

    # Completion — load early but we'll override later (core zsh `compsys` which carapace uses)
    zgenom prezto completion

    # fzf-related (important order) replace zsh's default completion selection menu with fzf
    zgenom load chitoku-k/fzf-zsh-completions
    zgenom load Aloxaf/fzf-tab   # must be after compinit, before widget wrappers

    # Git and other utility prezto modules
    # zgenom prezto command-not-found
    # zgenom prezto archive
    zgenom prezto git
    # interactive gnu utilities on BSD
    zgenom prezto gnu-utility

    # Syntax & suggestions — load before prompt
    # `zgenom prezto syntax-highlighting` but fast-syntax-highlighting quicker
    zgenom load zdharma-continuum/fast-syntax-highlighting
    # this is slow (up down arrow substring search) and mostly redundant with fzf
    # zgenom prezto history-substring-search
    zgenom prezto autosuggestions

    # ssh agent for persistent connections, uses `ps -U` etc.
    if ps -U &>/dev/null; then
        zgenom prezto ssh
    fi

    # prezto options
    zgenom prezto editor key-bindings 'emacs'
    # zgenom prezto prompt theme 'steeef'

    # mostly redundant with `starship`
    # zgenom prezto prompt

    # Load prezto tmux when tmux is installed
    if hash tmux &>/dev/null; then
        zgenom prezto tmux
    fi

    # add binaries
    # https://github.com/tj/git-extras/blob/master/Installation.md
    # zgenom bin tj/git-extras

    # save all to init script
    zgenom save

    # Compile your zsh files
    zgenom compile "$HOME/.zshrc"

    # You can perform other "time consuming" maintenance tasks here as well.
    # If you use `zgenom autoupdate` you're making sure it gets
    # executed every 7 days.

    # Lazy mise
    mise() {
      unset -f mise
      eval "$(mise activate zsh)"
      mise "$@"
    }
fi

# Deduplicate fpath (helps prevent unnecessary cache rebuilds)
typeset -gU fpath
fpath=(${(u)fpath})

# Fast compinit for Linux — rebuild cache only once per day (day-of-year check)
autoload -Uz compinit

if [[ ! -f ~/.zcompdump ]] || [[ "$(date +'%j')" != "$(date +'%j' -r ~/.zcompdump 2>/dev/null || echo '0')" ]]; then
    compinit -i
else
    compinit -C
fi

# ctrl+space can autocomplete, not tab
bindkey '^ ' autosuggest-accept

export CARGO_HOME="${HOME}/.cargo"
export GO_HOME="${HOME}/go"
export PATH="$PATH:${CARGO_HOME}/bin:${GO_HOME}/bin"

# https://unix.stackexchange.com/questions/110240/why-does-ctrl-d-eof-exit-the-shell
set -o ignoreeof

source "${ZDOTDIR:-$HOME}/.zsh_aliases"

# Local machine specific shell setup that we don't want to commit to source control
if [[ -s "${ZDOTDIR:-$HOME}/.zshrc.local" ]]; then
    source "${ZDOTDIR:-$HOME}/.zshrc.local"
fi

# Carapace (after compinit + fzf-tab)
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# fzf shell integration (modern way — works with package-installed fzf)
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi

# Smarter CD
eval "$(zoxide init zsh)"

# PROMPT
#
# Easy to get these all working on Linux, but in Windows Msys2 little if anything works reliably inside Windows Terminal
# Cmder also breaks - does freeze input handling. Windows Terminal problems *maybe* prompt related, as
# occasionally seems to create a stuck child process of zsh that blocks stdin
#
# Starship.rs (requires a binary, written in Rust) is fastest and clean to use with `starship.toml` for config
# It's a cross platform and cross shell *Prompt*: https://starship.rs/
# cargo install starship | choco install starship etc. | https://github.com/starship/starship/releases/download/v1.1.1/
#
# - Requires a "Nerd Font" with lots of glyphs: https://www.nerdfonts.com/#home
#   Change terminal font to match, e.g. CaskaydiaCove NF, FiraMono NF, JetBrainsMono NF
# - Add ~/.config/starship.toml to dotfiles
# - If not available in the standard PATH, we should have compile the starship binary with rust + `cargo install`
#   so expect to find it in $CARGO_HOME/bin
eval "$(starship init zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# profile end:
# zprof

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
