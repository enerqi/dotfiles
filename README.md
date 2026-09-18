# dotfiles

## Clone to existing home directory

- `git clone https://github.com/enerqi/dotfiles.git tempdir; mv tempdir/.git ~; rm -rf temp-dir; cd ~; git checkout .`

## ZSH Setup

### With these dotfiles

- Install `zsh` with your package manager
- Install [zgenom](https://github.com/jandamm/zgenom) zsh plugin manager from Git:

```
git clone https://github.com/jandamm/zgenom.git "${HOME}/.zgenom"
```

- Install [starship](https://starship.rs/guide/#%F0%9F%9A%80-installation) shell prompt tool (see cargo commands below)
- Install [zoxide](https://github.com/ajeetdsouza/zoxide#installation) i.e.

```
curl -sS https://webinstall.dev/zoxide | bash
```

- Install [carapace](https://github.com/carapace-sh/carapace-bin) cross-shell completion library

```
echo "deb [trusted=yes] https://apt.fury.io/rsteube/ /" | sudo tee /etc/apt/sources.list.d/fury.list
sudo apt-get update && sudo apt-get install carapace-bin
```

- Optional suggested other binaries include [ripgrep - rg](https://crates.io/crates/ripgrep#installation) and
  [fd-find - fd](https://crates.io/crates/fd-find#installation).
  All buildable with `cargo install ...` (and often available with `cargo binstall ...`).

Then add local machine specific definitions as desired:

```
.zshrc.local
.profile  (graphical login environment variables - X11 only, see below)
.xinitrc/.xsession (running graphical programs)
.zprofile.local (login shells - rarely needed)
```

- `.zprofile` / `~/.zprofile.local`  shouldn't change the key bindings, aliases, functions or shell options but could set the PATH for non-interactive or login commandline programs.

**`~/.profile` is X11-only, and that matters on Wayland.** Under GDM+Xorg,
`/etc/X11/Xsession` sourced `~/.profile`, so i3 and every child inherited
whatever it exported - which is how `$HOME/bin` and `$HOME/.local/bin` used to
reach everything. `gdm-wayland-session` does **not** do this: it runs the
compositor directly as a PAM session child, so the environment is only what
`pam_env` sets from `/etc/environment`. And zsh never reads `~/.profile` in any
case - it has its own chain (`.zshenv` -> `.zprofile` (login) -> `.zshrc`).

Consequence under sway: `~/.profile` sets nothing for anyone. PATH additions
must go in `.zprofile` (this repo puts `$HOME/bin` and `$HOME/.local/bin`
there; `.zshenv` sources it for non-login shells too, so every zsh gets them).
Symptom when this is wrong: `.zshrc` dies with `command not found: zoxide` and
`z`/`zi` never get defined - which looks like a plugin problem but is not.

`~/.config/environment.d/*.conf` does not help here either: it is read by
`systemd --user`, and sway runs in `session-N.scope`, not under
`user@1000.service`. For programs sway launches directly (not via a shell) use
an absolute path in the sway config - see the Sway section.

- `.xinitrc` (startx) / `.xsession` (xdm) run window manager independent programs after graphical login. X11 only; nothing sources them under Wayland.

## NuShell Setup

- set `XDG_CONFIG_HOME` if on Windows to `C:/Users/<you>/.config`

## WezTerm Terminal Setup
- install [wezterm](https://wezfurlong.org/wezterm/index.html) (recent nightly as of early 2026 for best experience)
- install nerd fonts by tweaking/running [`~/bin/fetch-fonts.sh`](./bin/fetch-fonts.sh)
  - optional for some things as wezterm bundles nerd fonts, but that script includes many fonts
  - `fc-list` to check font names used in `.config/i3/config` and `.config/alacritty/alacritty.toml` or with wezterm
    `wezterm ls-fonts --list-system`

## Window Manager Setup

- install [i3 window manager](https://i3wm.org/downloads/) >= *v4.20*
  - `i3wm i3lock-fancy i3blocks` (not `i3` meta package as we want the rust status bar)
  - `i3status-rs` is **not** in `~/bin` any more - see the Sway section
- `apt install compton pulseaudio pavucontrol` (compositor, sound panel control, i3 volume control etc.)

### Sway (Wayland)

Keyboard reference: [KEYMAP.md](./KEYMAP.md).

Ubuntu 26.04 offers sway as a session alongside GNOME. These dotfiles carry a
working `~/.config/sway/config` ported from the i3 one, so onboarding is:

```
sudo apt install sway swaylock swayidle fuzzel grim slurp wl-clipboard \
    xdg-desktop-portal-wlr dunst wlogout brightnessctl playerctl \
    cliphist blueman udiskie btop wtype \
    qalc wf-recorder wlsunset hyprpicker kanshi
```

No compton (sway composites itself); `i3status-rs` drives swaybar unchanged.
It is not packaged for Ubuntu, so install it with cargo - and with the
`pipewire` feature, which is what gives the `privacy` block its mic and
screen-share indicator rather than camera-only:

```
sudo apt install libpulse-dev libdbus-1-dev libsensors-dev libnotify-dev libssl-dev
cargo install i3status-rs --features pipewire
```

That lands in `~/.cargo/bin`, which is where the sway config points (sway's PATH
does not include it, so the path is explicit). The 24MB binary that used to be
committed to `~/bin` is gone from the repo - it was two minor versions stale and
built without `pipewire`. `dmenu_run` still works via XWayland; `$mod+d` uses fuzzel because
`i3-dmenu-desktop` speaks i3 IPC. `i3lock`/`i3-nagbar`/`xsetroot` are replaced
by `~/bin/sway-lock`/`swaynag`/`swaymsg output bg`.

`dunst` is not optional: nothing else provides `org.freedesktop.Notifications`
under sway, so without it every `notify-send` is silently dropped. It is chosen
over mako because i3status-rs's `notify` block (the DND toggle) only supports
dunst and swaync.

Then, **while docked**, run `~/bin/sway-outputs` and paste the real output
names into `~/.screenlayout/sway-outputs.env`. Sway names differ from xrandr
(`eDP-1-1` -> `eDP-1`), and `$mod+y` / `$mod+Shift+y` / `Ctrl+$mod+y` read that
file. The layout scripts are dual-mode: swaymsg under sway, xrandr otherwise.

Two things that will silently break a fresh install:

- **`~/.config/sway/config` must exist.** Without it sway falls back to
  `~/.config/i3/config`, which skips `/etc/sway/config.d/50-systemd-user.conf`
  and so never runs `systemctl --user import-environment WAYLAND_DISPLAY ...`.
  The result is a dead `xdg-desktop-portal` (file pickers, screen share and
  screenshots all fail). That import is the first exec in the config; keep it
  there.
- **sway ignores `/etc/default/keyboard`** and defaults every keyboard to us,
  so the GB laptop keyboard needs
  `input "1:1:AT_Translated_Set_2_keyboard" xkb_layout gb`. Set it per device,
  not with `input type:keyboard`, which would also hit waynergy's virtual
  keyboard (see below). `swaymsg -t get_inputs` lists identifiers.

Also note: programs sway starts do **not** inherit `$HOME/bin` or
`$HOME/.local/bin` (see the `~/.profile` note in the ZSH section), so the sway
config calls them by absolute path. A bare `exec waynergy` fails silently.

### Bar, lock screen and idle

swaybar + `~/.cargo/bin/i3status-rs`. Beyond the usual blocks the config adds
`privacy` (camera in use), `keyboard_layout` (gb vs us at a glance), `notify`
(DND toggle), `packages` (pending apt updates), a `net` click action
(left = `nmtui`, right = `nm-connection-editor` - no tray applet needed), and a
power button that launches `wlogout`.

The power button is a `custom` block, deliberately **not** i3status-rs's `menu`
block: that shows one item at a time and needs click-then-scroll-then-click to
reach anything past the first entry. `wlogout` gives a real popup grid;
`~/.config/wlogout/layout` defines it, and `$mod+Shift+x` opens the same thing.

The `privacy` block uses two drivers: `v4l` for the camera and `pipewire` for
mic and screen-share. `pipewire` is only accepted by a binary built with that
cargo feature - prebuilt ones reject it as a config error, which is why the
install above passes `--features pipewire`.

Locking goes through `~/bin/sway-lock` from all four call sites (both keybinds,
swayidle's idle timeout, and `before-sleep`) so they cannot drift apart. It
passes `--indicator-idle-visible`: without it swaylock paints a flat colour and
draws nothing until a key is pressed, so a locked screen is indistinguishable
from a powered-off one - very confusing when resuming from hibernate.

### Menus, pickers and input

One command palette on **`$mod+BackSpace`** (`~/bin/fuzzel-menu`) reaches Wi-Fi,
audio output, clipboard history, Bluetooth, screenshots, display layout,
keybindings, lock and power. BackSpace rather than `$mod+space` because it is
easier to reach on the Glove80; `focus mode_toggle` took `$mod+space` in
exchange, which is i3/sway's own default for it.

Everything is a small script in `~/bin` over `fuzzel --dmenu`, so it all looks
like the launcher instead of like four unrelated tools:

| Script | Does | Why not the obvious thing |
| --- | --- | --- |
| `fuzzel-wifi` | nmcli picker, signal bars, saved-network connect | `nmtui` is ncurses and matches nothing; `iwgtk`/`impala` are iwd-only and this is NetworkManager |
| `fuzzel-audio` | output switcher, mute, mixer | parses `pactl -f json`, not `wpctl status` tree output. Also moves already-playing streams, or switching looks like it did nothing |
| `fuzzel-clipboard` | cliphist history picker | `wl-clipboard` alone keeps only the current selection |
| `sway-keys` | searchable cheatsheet of all ~100 bindings | sway has none; parses the config so it cannot go stale. `--list` prints instead |
| `fuzzel-windows` | switcher across all workspaces | alt-tab only cycles the current workspace, useless with 20. Focuses by `con_id`, not title (titles repeat and change) |
| `fuzzel-emoji` | emoji/symbol picker, copies **and** types | names come from python `unicodedata`, so there is no data file to go stale (~2300 chars) |
| `fuzzel-power-profile` | performance / balanced / power-saver | `power-profiles-daemon` was already running with nothing exposing it |
| `sway-lid` | lid close/open behaviour | drops the internal output when docked, locks when not |
| `fuzzel-calc` | qalc in the launcher - units, currency, percentages | stays open after each answer and copies the result |
| `fuzzel-record` | screen recording, one entry point that starts **and** stops | a separate stop you have to find is how you end up with a 40-minute file. SIGINT so the container is finalised |
| `fuzzel-vpn` | work OpenVPN + Surfshark, with tunnel status | the work profile needs `sudo` **and** prompts for user/pass (inline certs + `auth-user-pass`), so it opens a terminal rather than pretending a menu can do it |
| `sway-nightlight` | wlsunset toggle | a toggle, not an autostart: you want it off instantly when judging a colour. Coords via `WLSUNSET_LAT`/`WLSUNSET_LON` |
| `fuzzel-screenshot` | region/window/screen → clipboard or file, 5s delay, annotate | `PrtSc` is an awkward reach on the Glove80, so `$mod+Shift+P` is the keyboard-first route. Saves to `~/Pictures/Screenshots` and copies too |
| `fuzzel-menu` | the palette itself | calls the above rather than reimplementing them |

Volume is **scroll-wheel on the swaybar sound block** (`step_width` there), not
a menu entry: re-opening fuzzel per 5% step flashed the window.

All fuzzel invocations pass `--no-exit-on-keyboard-focus-loss`. Sway defaults to
`focus_follows_mouse`, so without it moving the pointer towards the menu focuses
whatever is underneath and fuzzel exits before you arrive.

Clipboard history runs as `wl-paste --type text --watch cliphist store` from the
sway config. `--type text` keeps images out of it; `fuzzel-clipboard --wipe`
clears it. Copies made on the Windows machine arrive here too, via waynergy.

**Touchpad:** sway applies no touchpad defaults whatsoever - no tap-to-click, no
natural scrolling, no disable-while-typing - so the config sets them under
`input type:touchpad`. Device type rather than id so it survives new hardware;
safe here because waynergy's virtual device registers as a pointer, not a
touchpad (unlike `type:keyboard`, which would catch its virtual keyboard).
`natural_scroll enabled` is the line to flip if the scroll direction feels wrong.

Other bindings added: `$mod+Tab` window switcher, `$mod+e` emoji,
`$mod+Shift+p` screenshot menu, `$mod+u` / `$mod+Shift+u` scratchpad show/move.
`$mod+n` / `$mod+Shift+n` re-show last notification / clear all (dunst keeps a
history; unbound, a missed notification is just gone). `$mod+Shift+t` pins a
floating window across workspaces.
To take a window back **out** of the scratchpad there is no dedicated command:
summon it with `$mod+u`, then `$mod+Shift+BackSpace` (floating toggle) tiles it
into the current workspace. (Scratchpad is on `u` rather than the i3
convention `$mod+minus` because `$mod+Shift+minus` is already volume-down.)

**Window rules:** there were none, so every settings dialog tiled into the
layout. `pavucontrol`, `blueman-manager`, `nm-connection-editor`, Nautilus and
dialog/menu/splash window types now float. Rules are doubled up on `app_id`
(native wayland) and `class` (XWayland). Note `window_type` takes an enum, not
a regex, so those cannot be collapsed into one alternation the way
`window_role` can.

**Cursor:** `seat seat0 xcursor_theme Adwaita 24`. Unset by default, which
means the fallback theme at the fallback size - small on a 4K output, and
XWayland apps disagree with native ones until it is set here.

**Launcher:** `~/.config/fuzzel/fuzzel.ini` must set `terminal=foot -e`.
Desktop entries with `Terminal=true` (btop++, Vim, Python, TeXInfo) are
launched *inside* a terminal, and fuzzel's built-in default is `xterm -e` -
not installed here, so those entries silently do nothing without it. The file
also matches fuzzel's font and colours to the bar.

**Terminal:** wezterm is the everyday one; `foot` is the throwaway used by the
palette (btop), the Wi-Fi picker (`nmtui`) and the VPN menu. Its default is
`monospace:size=8`, unreadable on a 1200p panel and worse on 4K, so
`~/.config/foot/foot.ini` matches the swaybar font instead and sets
`dpi-aware=yes` for the external display.

**Displays:** `kanshi` applies a profile on hotplug, config in
`~/.config/kanshi/config`. Match on `make model serial` rather than `DP-N` -
connector numbering moves between docks and reboots, the monitor's identity
does not. The manual `$mod+y` layouts still override it until the next plug
event. The docked profiles are placeholders until filled in from
`~/bin/sway-outputs`.

**VPN indicator:** a `custom` block testing for a `tun`/`wg` interface, not
i3status-rs's `vpn` block - that only drives nordvpn, mullvad and tailscale,
and this machine runs Surfshark. Interface detection works whatever the
provider, and the block hides when no tunnel is up. Clicking it opens
`fuzzel-vpn`, which also drives the work OpenVPN profile via `~/vpn-gc.sh`
(a symlink to a script outside this repo).

**Removable media:** `udiskie --automount --notify --no-tray` from the sway
config. GNOME did this through gvfs; under sway nothing does, so a USB stick
would simply never appear.

### Hibernate

Ubuntu ships hibernation disabled twice over, so both need undoing.

`sudo ~/bin/enable-hibernate.sh` does both halves, then reboot. It is
idempotent and aborts on preflight failure (kernel lockdown, non-ext4 root,
insufficient space). What it fixes:

1. **Swap too small.** Hibernate writes a full memory image to swap, so swap
   must be >= RAM, and Ubuntu's default `/swap.img` is a few GB. The script
   resizes it (with `dd`, not `fallocate` - unwritten extents are unusable for
   resume), computes `resume_offset` via `filefrag`, writes `RESUME=` for the
   initramfs, adds `resume=UUID=... resume_offset=N` to GRUB, and regenerates
   both. Works fine with LUKS+LVM: the initramfs unlocks before resume.
2. **polkit denies it.** `/usr/share/polkit-1/rules.d/com.ubuntu.desktop.rules`
   contains "Disable hibernate by default in Ubuntu", returning
   `polkit.Result.NO` unconditionally. So `sudo systemctl hibernate` works (root
   bypasses polkit) while a desktop button gets
   `Call to Hibernate failed: Access denied`. The script installs an override in
   `/etc/polkit-1/rules.d/` (evaluated before `/usr/share`, first result wins),
   scoped to active local sudo-group users. polkitd reloads with no restart.

Check with `busctl --system call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanHibernate`.
Note the return values: `na` means unsupported, **`no` means permission
denied** - they are easy to confuse when diagnosing.

This laptop's firmware offers only `s2idle` (`/sys/power/mem_sleep`), not `deep`
/S3, so plain suspend still draws real power - which is why hibernate is worth
the trouble here. `systemctl suspend-then-hibernate` gets both.

### Keyboard/mouse sharing under sway: waynergy

Deskflow does not work as a client under sway. Its wayland backend needs the
`org.freedesktop.portal.RemoteDesktop` portal, which only the GNOME and KDE
backends implement - `xdg-desktop-portal-wlr` provides just Screenshot and
ScreenCast. Deskflow still works from the GNOME session if ever needed.

[waynergy](https://github.com/r-c-f/waynergy) replaces it on the client side
only; the Windows deskflow server is unchanged (it identifies as Barrier 1.8).
It drives the wlroots virtual pointer/keyboard protocols directly and syncs
the clipboard via `wl-clipboard`.

```
sudo apt install meson ninja-build libwayland-dev libwayland-bin \
    libxkbcommon-dev libtls-dev wl-clipboard
git clone https://github.com/r-c-f/waynergy.git ~/src/waynergy
cd ~/src/waynergy && meson setup build --prefix="$HOME/.local" && ninja -C build install
```

Config is `~/.config/waynergy/config.ini` (in this repo). Two machine-local
things are not, and both are required:

1. **Client certificate.** Deskflow does mutual TLS. Without a client cert the
   handshake succeeds and the server then sends *nothing* - it looks like a
   hang. Point waynergy at the deskflow cert:

   ```
   mkdir -p ~/.config/waynergy/tls && chmod 700 ~/.config/waynergy/tls
   ln -sfn ~/.config/Deskflow/tls/deskflow.pem ~/.config/waynergy/tls/cert
   ```

   Regenerate via deskflow when it expires; the symlink follows.

2. **Windows keycodes.** A Windows server sends PS/2 set-1 scancodes that no
   stock xkbcommon keycodes section understands - symptom is working mouse and
   gibberish keys. `~/.config/waynergy/xkb_keymap` (in this repo) handles it,
   but the keycodes file it includes must be installed:

   ```
   mkdir -p ~/.config/xkb/keycodes
   cp ~/src/waynergy/doc/xkb/keycodes/win ~/.config/xkb/keycodes/win
   ```

   Its `xkb_symbols` layout must match the **Windows** machine (currently
   `us`, since the Glove80 there is set to English (US) to avoid dead keys) -
   not this laptop's GB layout.

Also check `name` in `config.ini` matches the screen name in the deskflow
server's layout.

Launch with an absolute path - `~/.local/bin` is added to PATH by the shell
rc files, but sway's `exec` inherits the session PATH, which lacks it, so a
bare `exec waynergy` fails silently. The sway config uses
`"${HOME}/.local/bin/waynergy"`.

`ninja install` also writes a `waynergy.desktop` with a hardcoded `/usr/bin`
path and `Terminal=true` (it is a daemon). `~/.local` is not tracked here, so
re-patch it after every install to get a working `$mod+d` entry:

```
sed -i "s|^Exec=.*|Exec=$HOME/.local/bin/waynergy|; s|^Terminal=true|Terminal=false|; \
        s|^StartupNotify=true|StartupNotify=false|" \
    ~/.local/share/applications/waynergy.desktop
```

Verify:

```
swaymsg -t get_inputs   # virtual keyboard English (US), built-in English (UK)
ss -tnp | grep 24800    # ESTAB to the server
waynergy -L debug       # if not
```

Expect one quirk: the first connection each start is rejected (`EBAD` /
`Protocol error`) and succeeds on retry ~10s later, because waynergy pushes
the clipboard before the server accepts one. `waynergy -n` avoids it but loses
the clipboard, so the delay is accepted.

## Assorted Development Tools

Some mentioned above and below.

- apt install `git zsh build-essential libsensors-dev libssl-dev cmake clang pkg-config postgresql-client golang`
  - `git config --global credential.helper cache`
  - separately install any `.ssh` keys from secret repository
- apt install `openvpn feh fonts-font-awesome`
- [LLVM install script for Apt](https://apt.llvm.org/)
- libs for compiling more things e.g apt install `libsdl2-dev libpulse-dev libnotmuch_dev libssl-dev libpipewire-0.3-dev`
- `gsimplecal`
- [mise](https://mise.jdx.dev/getting-started.html) for python/node etc. version management on Linux
  - `mise use -g node@lts` etc.
- [fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#using-git) fuzzy finder from git or os packages
- [sublime text / sublime merge](https://www.sublimetext.com/docs/linux_repositories.html) apt packages
- docker binaries - apt install `docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
  - [permission issue](https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue) (`sudo usermod -aG docker $USER` etc.)
  - apt install `python3-setuptools` if missing distutils problem with `docker compose` commands
- [rustup](https://rustup.rs/)
  - `cargo install cargo-binstall`
  - `cargo binstall -y starship` + `zoxide` + `bat`
- install some sync service, e.g. [tresorit](https://tresorit.com/)
- `firefox` sync for custom settings and extensions
- `chrome` plus `ublock origin` extension for commonly used browser dev tools

## Sublime Text Setup

With a fresh sublime install

- install package control from the sublime command pallette

After that we are going back to (manually) using a sync service (e.g. Dropbox, Tresorit, One Drive etc.) as the
formerly useful `SyncSettings` sublime package is (currently in 2024) unmaintained and not working.

Sync `%USERPROFILE%/AppData/Roaming/Roaming/Sublime Text/Packages/User` (windows) to another machine. E.g. on Linux:

```
cd ~
ln -s ~/.config/sublime-text/Packages/User sublime-user-packages
```

Delete/move existing files and then you can sync into `~/sublime-user-packages` (e.g. "selective sync" tresor in tresorit to that dir).

Might need to hard link (e.g. mklink /H) `"Default (Windows).sublime-keymap"` to `"Default (Linux).sublime-keymap"`
