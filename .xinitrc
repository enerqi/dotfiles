# `startx` will trigger this file
# if not using a desktop login manager then could start i3 etc. from here
# exec i3

# xstartup scripts are executed by /bin/sh which is /bin/dash.
# Debian sources .profile at graphical login, which is where we do graphical
# setup environment variables (e.g. for sublime text).
~/bin/random_background.sh
