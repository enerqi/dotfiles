#!/bin/bash
# Build SwayFX (sway fork with rounded corners, blur, shadows) into ~/.local.
#
# Deliberately NOT a system install. SwayFX builds a binary called `sway`, so
# installing it over the packaged one would replace the compositor with no way
# back if it misbehaves. Into ~/.local it is just another binary, selected by a
# separate GDM session entry, with stock sway still there to log into.
#
# Two projects: SceneFX is the effects library, SwayFX is the compositor that
# uses it. SwayFX must be built against the same wlroots the system sway uses
# (0.19 here) or it will not run.
set -euo pipefail

PREFIX="$HOME/.local"
SRC="$HOME/src"

# Pinned, not master. Ubuntu 26.04 ships wlroots 0.19 (which is what sway 1.11
# is built against); SceneFX and SwayFX master have both moved to wlroots 0.20
# and will not configure against it. These two tags are the wlroots-0.19 pair,
# and SwayFX 0.5.3 asks for `scenefx-0.4` by name.
SCENEFX_TAG="0.4.1"
SWAYFX_TAG="0.5.3"
export PKG_CONFIG_PATH="$PREFIX/lib/x86_64-linux-gnu/pkgconfig:$PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="$PREFIX/lib/x86_64-linux-gnu:$PREFIX/lib:${LD_LIBRARY_PATH:-}"

need() { command -v "$1" >/dev/null || { echo "missing: $1" >&2; exit 1; }; }
need meson; need ninja; need git; need pkg-config

echo "== preflight =="
if ! pkg-config --exists wlroots-0.19; then
    echo "FAIL: wlroots-0.19 dev files not found. Install:" >&2
    echo "  sudo apt install libwlroots-0.19-dev libpixman-1-dev libdrm-dev \\" >&2
    echo "       libinput-dev libjson-c-dev libpcre2-dev libevdev-dev \\" >&2
    echo "       libcairo2-dev libpango1.0-dev libgbm-dev libseat-dev \\" >&2
    echo "       libxcb1-dev scdoc" >&2
    exit 1
fi
echo "wlroots: $(pkg-config --modversion wlroots-0.19)"
echo "system sway: $(sway --version)"

mkdir -p "$SRC"

echo "== scenefx =="
if [[ -d "$SRC/scenefx/.git" ]]; then
    git -C "$SRC/scenefx" fetch --tags --force
else
    git clone https://github.com/wlrfx/scenefx.git "$SRC/scenefx"
fi
cd "$SRC/scenefx"
git checkout -q "$SCENEFX_TAG"
echo "scenefx: $SCENEFX_TAG (wants $(grep -oE 'wlroots-0\.[0-9]+' meson.build | head -1))"
rm -rf build
meson setup build --prefix="$PREFIX" -Dexamples=false
ninja -C build install

echo "== swayfx =="
if [[ -d "$SRC/swayfx/.git" ]]; then
    git -C "$SRC/swayfx" fetch --tags --force
else
    git clone https://github.com/WillPower3309/swayfx.git "$SRC/swayfx"
fi
cd "$SRC/swayfx"
git checkout -q "$SWAYFX_TAG"
echo "swayfx: $SWAYFX_TAG (wants $(grep -oE 'wlroots-0\.[0-9]+' meson.build | head -1))"
rm -rf build
# sd-bus-provider=libsystemd matches how Ubuntu builds sway.
meson setup build --prefix="$PREFIX" -Dsd-bus-provider=libsystemd
ninja -C build install

# SwayFX also installs swaymsg/swaybar/swaynag. ~/.local/bin comes before
# /usr/bin on PATH, so those would shadow the packaged ones even while running
# stock sway - every ~/bin/* script here calls `swaymsg`. Keep only the
# compositor; the system tools speak the same IPC and work with both.
for shadowed in swaymsg swaybar swaynag swaybg; do
    rm -f "$PREFIX/bin/$shadowed"
done

# And the compositor itself: SwayFX installs as `sway`, which would shadow the
# packaged sway for every shell on PATH - including `sway --validate`, which
# then fails on the missing libscenefx. Renamed; the session wrapper calls it
# by this name.
mv -f "$PREFIX/bin/sway" "$PREFIX/bin/swayfx"

echo
echo "DONE."
echo "  binary:  $PREFIX/bin/swayfx"
echo "  stock:   $(command -v sway) ($(sway --version))"
echo
echo "Next: install the session entry so GDM offers 'Sway FX', then log out:"
echo "  sudo install -m 644 ~/swayfx-session.desktop \\"
echo "      /usr/share/wayland-sessions/swayfx.desktop"
