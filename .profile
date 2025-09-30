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
export CARGO_HOME="$HOME/.cargo"

# tresorit
export PATH="$PATH:$HOME/.local/share/tresorit"

# Mouse trackball button settings
# Called in .xsessionrc
# KENSINGTON_ID=$(xinput list | grep "Kensington" | head -n 1 | sed -r 's/.*id=([0-9]+).*/\1/')
# [[ ! -z "$KENSINGTON_ID" ]] && xinput --set-button-map ${KENSINGTON_ID} 8 3 1 5 4 0 0 2

# custom additional mode for dell 3007 wfp on display DP-1-3
# cvt needs running with -r for reduced blanking to make the screen tolerable
# > cvt -r 2560 1600 60
#xrandr --newmode "2560x1600_60.00"  268.50  2560 2608 2640 2720  1600 1603 1609 1646 +hsync -vsync
#xrandr --addmode DP-1-3 "2560x1600_60.00"
. "$HOME/.cargo/env"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
