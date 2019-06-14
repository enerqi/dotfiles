# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin directories
PATH="$HOME/bin:$HOME/.local/bin:$PATH"


# Debian sources .profile at graphical login. So setting up environment variables here.
# Starting graphical programs/scripts can be .xinitrc/.xsession
export CARGO_HOME="$HOME/.cargo/bin"
export RUST_SRC_PATH="$HOME/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src"

# cargo home + tresorit
export PATH="$PATH:$CARGO_HOME:$HOME/.local/share/tresorit"

# cargo installed binaries
export PATH="$HOME/.cargo/bin/bin:$PATH"

# miniconda - end of path for graphical programs
export PATH="$PATH:$HOME/miniconda3/bin"

