
# Local machine specific login shell setup that we don't want to commit to source control
if [[ -f ~/.login.local ]]; then
    source ~/.login.local
fi

# All linux machines regardless of host - ensure fixed annoying <Super+P> key combo setting projector mode
# which interferes with the i3 WM shortcuts
[[ `uname` = Linux ]] && which dconf > /dev/null && dconf write /org/gnome/settings-daemon/plugins/media-keys/active false
