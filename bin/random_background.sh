#!/bin/bash
# Pick a random wallpaper and apply it.
# Works under both sway (swaymsg output bg) and X11/i3 (feh).
#
# Candidates come from ${XDG_CONFIG_HOME:-$HOME/.config}/wallpapers/nature.txt
# when that file lists at least one readable image; otherwise every image in
# /usr/share/backgrounds is fair game.

dir=/usr/share/backgrounds
list="${XDG_CONFIG_HOME:-$HOME/.config}/wallpapers/nature.txt"

candidates=()

if [ -r "$list" ]; then
    while IFS= read -r line; do
        line="${line%%#*}"                     # strip comments
        line="${line#"${line%%[![:space:]]*}"}" # trim leading space
        line="${line%"${line##*[![:space:]]}"}" # trim trailing space
        [ -z "$line" ] && continue
        case "$line" in
            '~/'*) line="$HOME/${line#\~/}" ;;
            /*)    ;;
            *)     line="$dir/$line" ;;
        esac
        [ -r "$line" ] && candidates+=("$line")
    done < "$list"
fi

if [ ${#candidates[@]} -eq 0 ]; then
    while IFS= read -r f; do
        candidates+=("$f")
    done < <(find "$dir" -maxdepth 1 -type f \
                  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \))
fi

[ ${#candidates[@]} -eq 0 ] && exit 0

img="${candidates[RANDOM % ${#candidates[@]}]}"

if [ -n "$SWAYSOCK" ] && command -v swaymsg >/dev/null; then
    swaymsg output '*' bg "$img" fill
else
    feh --bg-scale "$img"
fi
