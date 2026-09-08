#!/bin/bash
# Pick a random wallpaper from /usr/share/backgrounds.
# Works under both sway (swaymsg output bg) and X11/i3 (feh).

dir=/usr/share/backgrounds
img=$(python3 -c 'import os,random,sys
d=sys.argv[1]
c=[f for f in os.listdir(d) if f.endswith(("jpg","png"))]
print(random.choice(c) if c else "")' "$dir")

[ -z "$img" ] && exit 0

if [ -n "$SWAYSOCK" ] && command -v swaymsg >/dev/null; then
    swaymsg output '*' bg "$dir/$img" fill
else
    feh --bg-scale "$dir/$img"
fi
