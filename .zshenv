# ZSH Startup
#

### .zshenv *always* read
# 1) Read /etc/zshenv 
#    If the RCS option is unset in this system file, all other startup files are skipped!
# 2) Next, read ~/.zshenv 
#
# Any shell started will use its values making attempts to override them from
# a parent process before starting a shell process pointless.  Use if you want
# a customised environment regardless of what the parent process was doing. If
# processes aren't happy with this customisation then they could explicitly
# use /bin/sh or /usr/local/bin/zsh -f (only run /etc/zshenv). 
#
# zshenv is the only script sourced by cron jobs (not interactive, not login child process
# because root ran). Put things for non-interactive shells. Changing
# syntax like EXTENDED_GLOB, limit.
# Since .zshenv is always sourced, it often contains exported variables that
# should be available to other programs. For example, $PATH, $EDITOR, and
# $PAGER are often set in .zshenv. Also, you can set $ZDOTDIR in .zshenv to
# specify an alternative location for the rest of your zsh configuration.

### .zprofile login shell only (prefer .zlogin)
# 3) /etc/zprofile 
# 4) ~/.zprofile
# .zprofile is basically the same as .zlogin except that it's sourced directly
# before .zshrc is sourced instead of directly after it. According to the zsh
# documentation, ".zprofile is meant as an alternative to `.zlogin' for ksh
# fans; the two are not intended to be used together, although this could
# certainly be done if desired."

### .zshrc interactive shell only
# 5) /etc/zshrc
# 6) ~/.zshrc
# For editing behaviour -> options/bindkey, history control, interactive only aliases,
# other non-exportable stuff.
# .zshrc is for interactive shell configuration. You set options for the
# interactive shell there with the setopt and unsetopt commands. You can also
# load shell modules, set your history options, change your prompt, set up
# zle and completion, et cetera. You also set any variables that are only
# used in the interactive shell (e.g. $LS_COLORS).

### .zlogin login shell only (instead of .zprofile)
# 7) /etc/zlogin
# 8) ~/.zlogin
# All login shells are interactive (hence only .zshenv of non-interactive shells)
# .zlogin is sourced on the start of a login shell. This file is often used to
# start X using startx. Some systems start X on boot, so this file is not
# always very useful.

### .zlogout
# .zlogout is sometimes used to clear and reset the terminal.


if [[ ! -o interactive ]]; then 
    
    # Setup for non-interactive shells


fi
