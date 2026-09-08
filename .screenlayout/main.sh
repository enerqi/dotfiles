#!/bin/sh
# 3 monitor: MAIN (4K, top left) - RIGHT (right of it) - LAPTOP (bottom right)
if [ -n "$SWAYSOCK" ] && command -v swaymsg >/dev/null; then
    . "${HOME}/.screenlayout/sway-outputs.env"
    swaymsg output "$MAIN"     enable mode 3840x2160 position 0 0
    swaymsg output "$RIGHT"    enable mode 1920x1080 position 3840 1080
    swaymsg output "$LAPTOP"   enable position 3840 2160
    swaymsg output "$DUAL_EXT" disable
else
    exec xrandr --output DVI-I-3-2 --mode 3840x2160 --pos 0x0 --rotate normal --output HDMI-1-3 --off --output HDMI-1-2 --off --output HDMI-1-1 --off --output DP-1-2 --off --output eDP-1-1 --primary --mode 1920x1080 --pos 3840x2160 --rotate normal --output DP-1-1 --off --output DVI-I-2-1 --mode 1920x1080 --pos 3840x1080 --rotate normal --output DP-1-3 --off --output DP-3 --off --output DP-2 --off --output DP-1 --off --output DP-0 --off
fi
