#!/bin/sh
# 2 monitor: external left, laptop right
if [ -n "$SWAYSOCK" ] && command -v swaymsg >/dev/null; then
    . "${HOME}/.screenlayout/sway-outputs.env"
    swaymsg output "$DUAL_EXT" enable mode 1920x1080 position 0 0
    swaymsg output "$LAPTOP"   enable position 1920 0
    swaymsg output "$MAIN"     disable
    swaymsg output "$RIGHT"    disable
else
    exec xrandr --output DP-1-3 --off --output HDMI-1-3 --off --output HDMI-1-2 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1-1 --off --output DP-1-2 --off --output eDP-1-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-1 --off --output DP-3 --off --output DP-2 --off --output DP-1-1 --off --output DP-0 --off
fi
