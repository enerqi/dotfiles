# SwayFX config.
#
# This exists as a separate file rather than as lines in the main config
# because every directive below is SwayFX-only: stock sway rejects them and
# refuses to load the config, which would leave no working session.
#
# So: the main config stays portable and loads under either compositor, and the
# SwayFX session is launched with `sway -c ~/.config/sway/config.fx`.

include ~/.config/sway/config

#
# Effects
#
# Restrained on purpose. Rounded corners and a soft shadow read as considered;
# heavy blur mostly reads as a screenshot. Blur is off by default here - it is
# the one effect with a real cost on battery, and this laptop is s2idle-only.

corner_radius 8

shadows enable
shadow_blur_radius 20
shadow_color #00000060
shadow_inactive_color #00000030
shadow_offset 0 2

# Dim what is not focused, gently. Useful with 20 workspaces and tabbed layouts
# where "which pane am I typing into" is a real question.
default_dim_inactive 0.08

# No animation settings: `animation_duration_ms` exists in SwayFX master's
# docs but not in 0.5.3, which is the wlroots-0.19 release this is pinned to.
# Adding it stops the config loading entirely.

# Blur: costs GPU and battery. Try it with `swaymsg blur enable` first.
# blur enable
# blur_passes 2
# blur_radius 4
# blur_xray disable

# Keep the bar and launcher sharp rather than blurred behind.
layer_effects "waybar" blur disable
layer_effects "fuzzel" blur disable
