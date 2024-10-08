# profile start:
# zmodload zsh/zprof

# The [configuration files][1] are read in the following order:

# 1.  _`/etc/zshenv`_
# 2.  _`${ZDOTDIR:-$HOME}/.zshenv`_
# 3.  _`/etc/zprofile`_
# 4.  _`${ZDOTDIR:-$HOME}/.zprofile`_
# 5.  _`/etc/zshrc`_
# 6.  _`${ZDOTDIR:-$HOME}/.zshrc`_
# 7.  _`${ZDOTDIR:-$HOME}/.zpreztorc`_
# 8.  _`/etc/zlogin`_
# 9.  _`${ZDOTDIR:-$HOME}/.zlogin`_
# 10. _`${ZDOTDIR:-$HOME}/.zlogout`_
# 11. _`/etc/zlogout`_

# ### zshenv

# This file is sourced by all instances of Zsh, and thus, it should be kept as
# small as possible and should only define environment variables.

# ### zprofile

# This file is similar to _zlogin_, but it is sourced before _zshrc_. It was added
# for [KornShell][2] fans. See the description of _zlogin_ below for what it may
# contain.

# _zprofile_ and _zlogin_ are not meant to be used together but can be done so.

# ### zshrc

# This file is sourced by interactive shells. It should define aliases, functions,
# shell options, and key bindings.

# ### zpreztorc

# This file configures Prezto.

# ### zlogin

# This file is sourced by login shells after _zshrc_. Thus, it should contain
# commands that need to execute at login. It is usually used for messages such as
# [_`fortune`_][3], [_`msgs`_][4], or for the creation of files.

# This is not the file to define aliases, functions, shell options, and key
# bindings. It should not change the shell environment.

# ### zlogout

# This file is sourced by login shells during logout. It should be used for
# displaying messages and for deletion of files.

# load [zgenom plugin manager](https://github.com/jandamm/zgenom), successor to and compatible with zgen
source "${HOME}/.zgenom/zgenom.zsh"

# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
zgenom autoupdate

# Everything in this if branch is loaded pre-compiled from an init script if it exists
# if the init script doesn't exist (use `zgenom reset` to clear the init script) then run all
# these (slow) zgenom functions
if ! zgenom saved; then
    echo "Creating a zgenom save"

    # Ohmyzsh base library
    zgenom ohmyzsh
    # plugins
    zgenom ohmyzsh plugins/mise

    # zgenom ohmyzsh plugins/git
    # zgenom ohmyzsh plugins/sudo
    # just load the completions
    # zgenom ohmyzsh --completion plugins/docker-compose

    # Install ohmyzsh osx plugin if on macOS
    # [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/osx

    # prezto options
    zgenom prezto editor key-bindings 'emacs'
    # zgenom prezto prompt theme 'steeef'

    # prezto and modules
    # If you use prezto and ohmyzsh - load ohmyzsh first.
    zgenom prezto
    zgenom prezto command-not-found
    zgenom prezto archive
    zgenom prezto environment
    zgenom prezto terminal
    zgenom prezto editor
    zgenom prezto history
    zgenom prezto directory
    zgenom prezto spectrum
    zgenom prezto utility
    zgenom prezto completion
    # additional completions
    zgenom load zsh-users/zsh-completions
    zgenom load chitoku-k/fzf-zsh-completions
    # Replace zsh's default completion selection menu with fzf
    # must be before suggestions/syntax highlighting
    zgenom load Aloxaf/fzf-tab
    zgenom prezto git
    zgenom prezto archive
    # must be before history-substring-search, autosuggestions and prompt (in that order)
    zgenom prezto syntax-highlighting
    zgenom prezto history-substring-search
    zgenom prezto autosuggestions
    # ssh agent for persistent connections, uses `ps -U` etc.
    if ps -U &>/dev/null; then
        zgenom prezto ssh
    fi
    # interactive gnu utilities on BSD
    zgenom prezto gnu-utility
    zgenom prezto prompt

    # Load prezto tmux when tmux is installed
    if hash tmux &>/dev/null; then
        zgenom prezto tmux
    fi

    zgenom load zsh-users/zsh-syntax-highlighting

    # add binaries
    # https://github.com/tj/git-extras/blob/master/Installation.md
    # zgenom bin tj/git-extras

    # will fetch fzf from github for us and setup keybindings
    zgenom load unixorn/fzf-zsh-plugin

    alias e='exa -1 -a'      # Lists in one column, hidden files.
    alias el='exa -l'        # Lists human readable sizes.
    alias er='el -R'         # Lists human readable sizes, recursively.
    alias ea='el -a'         # Lists human readable sizes, hidden files.
    alias es='el -s size'    # Lists sorted by size, largest last.
    alias ex='el -s extension' # Lists sorted by extension (GNU only).
    alias em='el -a | "$PAGER"' # Lists human readable sizes, hidden files through pager.
    alias et='el -s created' # Lists sorted by date, most recent last.
    alias ec='el -s modified' # Lists sorted by date, most recent last, shows change time.
    alias eu='el -s accessed' # Lists sorted by date, most recent last, shows access time.
    alias ls='lsd'

    # save all to init script
    zgenom save

    # Compile your zsh files
    zgenom compile "$HOME/.zshrc"
   # zgenom compile $ZDOTDIR

    # You can perform other "time consuming" maintenance tasks here as well.
    # If you use `zgenom autoupdate` you're making sure it gets
    # executed every 7 days.
fi

# ctrl+space can autocomplete, not tab
bindkey '^ ' autosuggest-accept

export CARGO_HOME="${HOME}/.cargo"
export GO_HOME="${HOME}/go"
export PATH="$PATH:${CARGO_HOME}/bin:${GO_HOME}/bin"

# https://unix.stackexchange.com/questions/110240/why-does-ctrl-d-eof-exit-the-shell
set -o ignoreeof

# Local machine specific shell setup that we don't want to commit to source control
if [[ -s "${ZDOTDIR:-$HOME}/.zshrc.local" ]]; then
    source "${ZDOTDIR:-$HOME}/.zshrc.local"
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

# https://spaceship-prompt.sh/
# The original, like starship.rs but much slower
# zgenom load mafredri/zsh-async
# zgenom load denysdovhan/spaceship-prompt spaceship

# agkozak-zsh-prompt
# Fast and generally nice and quite similar to a standard starship setup
# !somehow prone to freeze ups in Windows terminal
# Uses async, but maybe only for git status
# zgenom load mafredri/zsh-async
# zgenom load agkozak/agkozak-zsh-prompt

# powerlevel10k
# another popular prompt, easy to follow the wizard to customise it, fast and async parts to it
# yet another prompt broken in Windows Terminal
# zgenom load romkatv/powerlevel10k powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# profile end:
# zprof
