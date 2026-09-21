# Desktop

Sway on Ubuntu 26.04, and the reasoning behind it. [README.md](./README.md) has
the quickstart - what to install and which key does what; this file is the long
form, kept because most of it is the record of something that did not work the
obvious way.

Keyboard reference: [KEYMAP.md](./KEYMAP.md).

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
sudo apt install sway swaybg swaylock swayidle waybar foot fuzzel \
    grim slurp wl-clipboard xdg-desktop-portal-wlr dunst wlogout \
    brightnessctl playerctl cliphist blueman udiskie btop wtype \
    gsimplecal qalc wf-recorder wlsunset hyprpicker kanshi
```

No compton (sway composites itself). The bar is **waybar**, from the archive -
see the bar section below. i3status-rs is still installed at
`~/.cargo/bin/i3status-rs` and is still the rollback, but **nothing runs it**.
It no longer has to be built with the `pipewire` feature either: that flag
existed purely for the `privacy` block, which waybar covers natively. A fresh
install can skip it entirely - these are kept only for the rollback path:

```
sudo apt install libpulse-dev libdbus-1-dev libsensors-dev libnotify-dev libssl-dev
cargo install i3status-rs
```

The 24MB copy that used to be committed to `~/bin` was removed from the repo in
`f143fe8` and added to `.gitignore`; the file is still on disk here, untracked. `$mod+d` uses fuzzel because `i3-dmenu-desktop` speaks i3 IPC. `i3lock`/`i3-nagbar`/`xsetroot` are replaced
by `~/bin/sway-lock`/`swaynag`/`swaymsg output bg`.

`dunst` is not optional: nothing else provides `org.freedesktop.Notifications`
under sway, so without it every `notify-send` is silently dropped. It is chosen
over mako because the DND toggle drives it through `dunstctl`
(`~/bin/waybar-dnd`), which mako has no equivalent of.

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

**waybar** (2026-09), replacing swaybar + `~/.cargo/bin/i3status-rs`. The
swaybar block is still in the sway config, commented out, as the rollback:
nothing was deleted and i3status-rust still works.

The reason for the move is the box model. swaybar draws with cairo and exposes
a fixed vocabulary - one font, a position, and colours for seven named
elements. Padding, rounded corners, margins, hover states and per-module
transitions are not expressible there *at any effort level*. waybar is a GTK3
widget on a layer-shell surface, so appearance is real CSS. That split is the
whole point: `~/.config/waybar/config.jsonc` is structure,
`~/.config/waybar/style.css` is appearance.

The palette is srcery, matching the i3status-rust theme it replaced, so the
switch was not also a colour change. Font size is set in exactly one place, in
the `*` rule: **16px, which is pango 12pt at this panel's 96dpi** - what the
old swaybar line asked for. The output is scale 1.0 and GTK
`text-scaling-factor` is 1.0, so no further correction applies.

21 modules, ported block-for-block from `.config/i3status-rust/config.toml`.
Fifteen map to native waybar modules. Six are `custom/`, and of those only
`custom/power` needs no script - it is a static glyph whose `on-click` is
`wlogout`. The other five have helpers in `~/bin`:

| script | why it is not a native module |
| --- | --- |
| `waybar-docker` | no docker module exists |
| `waybar-vpn` | the native `vpn` module covers only nordvpn/mullvad/tailscale; this detects the tunnel *interface*, so it works whatever the provider |
| `waybar-dnd` | dunst pause state + toggle, in one script so the two cannot drift |
| `waybar-packages` | no apt module |
| `waybar-keyboard` | see the gotchas below |

Every module that can do something on click now does, and the newly clickable
ones reuse scripts that already existed: battery opens
`~/bin/fuzzel-power-profile` (which nothing else exposed outside the command
palette), and cpu/load/memory/temperature/disk all open `~/bin/btop-term`.
Network is `fuzzel-wifi` (not `nmtui` - ncurses in a terminal looks nothing
like the rest of the desktop), right-click `nm-connection-editor`. Volume
scrolls in-module and opens `fuzzel-audio`, right-click `pavucontrol`.

Because five bar modules open btop, `~/bin/btop-term` grew a single-instance
guard - clicking two of them used to stack two identical windows. It focuses an
existing btop via `swaymsg '[app_id="btop"] focus'`, whose **exit status is the
test**: it exits 2 with "No matching node." when nothing matches, so no tree
parsing is needed. The guard only applies with no arguments, so
`btop-term --flag` still gets its own window. This deliberately changes the
command palette and the `.desktop` launcher too, which is the point - one
implementation, not three.

The two popup scripts (`waybar-docker-ps`, `waybar-packages-list`) float via
`for_window [app_id="waybar-popup"]`, with **no `resize set`** - the same trap
documented for btop above. They size with `--window-size-chars`, and a pixel
`resize set` overrides that and squashes the columns.

waybar is launched by `~/bin/waybar-launch`, not directly. `exec_always`
re-runs on every `swaymsg reload` and waybar has no single-instance guard, so a
bare `exec_always waybar` stacks a second bar on the same layer on every
reload - which reads as the bar being broken rather than as two bars. The
wrapper kills the old one and waits for it to actually exit, bounded at ~2s so
a wedged process cannot leave the session with no bar at all.

`wlogout` is still the power button, still a real popup grid rather than a
menu that needs click-then-scroll-then-click; `$mod+Shift+x` opens the same
thing.

#### Window decoration

`default_border pixel 2` (no title bars) with `gaps inner 6` and
`smart_gaps on`. Dropping title bars is affordable because waybar's centre
module shows the focused window's title - the title bar had become chrome
repeating what the bar already says. Sublime Text is the exception
(`border normal 2`): with several windows open the title is the only thing
telling them apart, and the bar only ever shows the *focused* one.

**`client.<class>` takes five arguments, not three.** `<border> <background>
<text> [<indicator> [<child_border>]]`, and `child_border` - the border around
the window itself, which is what `default_border pixel` actually draws -
**silently inherits `<background>` when omitted**. The three-argument form here
therefore drew a black focused border (#000000, the old title bar background)
and a #333333 unfocused one: invisible against a dark wallpaper, and
indistinguishable from each other. That was fine while title bars carried the
focus signal and became a real problem the moment they were removed. The
focused colour is now #2c78bf, the same blue waybar uses for the focused
workspace, so the two "this has focus" signals match. `<indicator>` (4th, which
marks the edge where the next window opens in a tiled container) was never set
either.

Two behaviours that make decoration changes look broken on `swaymsg reload`:

- `default_border` applies to **newly created windows only**. Existing ones
  keep their border type; `swaymsg '[title=".*"] border pixel 2'` retrofits them.
- `gaps` in the config applies to **newly created workspaces only**. Existing
  workspaces keep whatever gap they had. Verified by resetting runtime gaps to
  0 and creating a fresh workspace, which came up with the configured 6.
  `swaymsg gaps inner all set 6` fixes the running session; a fresh login is
  correct everywhere.

Not available in sway 1.11 at any setting: rounded corners, gradients, shadows,
animations, dim-inactive, and window icons (i3's `title_window_icon` has no
sway equivalent - `man 5 sway` has no such directive). Those need a different
compositor; see the SwayFX section below for why that route is closed here.

The icon gap is worth a note because it is not a Sublime Text quirk, which is
what it looks like: sway draws no icon for *any* window. i3's directive reads
`_NET_WM_ICON`, an X11 property with no Wayland analogue - icons there resolve
`app_id` against a desktop entry, and sway declined to ship an XWayland-only
path. Sublime is fully equipped for it (`app_id=sublime_text`, native
`xdg_shell` rather than XWayland, `Icon=sublime-text` in its desktop entry,
PNGs installed under `hicolor`); there is simply nothing to configure.

Only the *image* route is closed, though. **Sway does have `title_format`**,
which takes `%title`, `%app_id`, `%class`, `%instance`, `%shell` and pango
markup when the font is a pango one (it is), so a Nerd Font glyph in a title
bar renders fine - `for_window [app_id="sublime_text"] title_format
"<span foreground='#f79a0e'></span>  %title"` works. Two reasons it is not
used: it looked bad at title-bar size, and with `default_border pixel 2` only
Sublime Text has a title bar to put it in. Note pango attributes need single
quotes - double ones passed through `swaymsg` arrive escaped and print as raw
markup rather than rendering.

So the marking is waybar's, via `icon: true` on `sway/window`, which draws the
genuine hicolor PNG and therefore covers every app with a desktop entry rather
than a hand-listed few. **`icon` is a separate GTK image widget, not a format
placeholder** - putting `{icon}` in `"format"` renders an empty label and the
title vanishes for every window, which looks like waybar crashing rather than
like a bad format string.

`rewrite` then strips the now-redundant suffix: with a 60-char `max-length`,
" - Sublime Text" is 15 characters repeating what the icon already said. Three
things about `rewrite` that are easy to get wrong - the pattern must match the
**whole** title rather than a substring, matching is case-insensitive and
cannot be turned off, and **every** matching rule is applied in sequence, so
overlapping rules compound rather than the first one winning. The rules here
are mutually exclusive by suffix for that last reason.

`wlr/taskbar` is the other route: it renders desktop-entry icons too, but it is
a different thing - a window list, not a marker on the focused title.

#### Closing a window that will not close

`$mod+Shift+Delete` is sway's `kill`, which only **asks** a window to close
(`xdg_toplevel.close`). A working app complies. A hung one never reads the
request, and nothing happens. `Ctrl+$mod+Shift+Delete` runs
`~/bin/sway-force-quit`, which signals the process sway reports for the focused
window instead: SIGTERM, then SIGKILL if that is ignored for 2s. It is the
sway stand-in for `xkill`.

It confirms first, through fuzzel with **No** as the default, because the
damage can be wider than the window in front of you:

- **One process can own many windows.** Every wezterm window is one process,
  so force-quitting "this terminal" closes them all. The prompt counts the
  windows sharing the PID and says so.
- **XWayland windows are refused.** Their PID is whatever the X client chose to
  advertise, possibly 0 or Xwayland's own, and killing Xwayland takes every X11
  app with it. `pkill <name>` is the route for those.
- sway, Xwayland, systemd and waybar are refused outright.

Liveness is read from `/proc/<pid>/stat`, not `kill(pid, 0)`: a killed process
lingers as a zombie until its parent reaps it, and `kill -0` succeeds on a
zombie. The first version therefore reported "survived SIGKILL" for a process
it had killed, and would have escalated to SIGKILL on an app that had already
exited cleanly on SIGTERM.

What prompted it: the snap **firmware updater**, after its own maximise button
was clicked. Sway has no maximise for a tiled window, so it never granted the
size; the app switched to its maximised layout anyway and never re-read the
size it was actually given. Its right-hand half - including its own close
button - was drawn off the edge of the window, and it sat at 100% CPU ignoring
the close request. Fullscreen and floating round-trips did not reset it; only
restarting the process does. Before killing a firmware tool, check the
`fwupd` daemon is idle (`busctl get-property org.freedesktop.fwupd /
org.freedesktop.fwupd Status` returns `1`): the daemon does the flashing and the
GUI is only a front end, so killing the GUI is safe - never the daemon mid-update.

**General rule: ignore apps' own minimise/maximise buttons under sway.** Sway
has no minimise at all, and maximise is where the failure above starts.
`$mod+p` is fullscreen, `$mod+Shift+t` sends a window to the scratchpad.

#### waybar gotchas found the hard way

- **GTK3 CSS is not web CSS, and a bad selector is fatal.** `:empty` does not
  exist there, and waybar *refuses to start* on it rather than skipping the
  rule. The centre island is therefore drawn by `#window`, which does expose an
  `empty` class, so it disappears with its content.
- **`sway/language` rendered as a bare `...`.** Not a format problem - a
  literal string ellipsized identically. The label requests zero width and GTK
  ellipsizes it; `min-length` is the fix. That module is no longer used, but
  the same failure will hit any module whose content is short.
- **`sway/language` also blanked intermittently**, which is why
  `~/bin/waybar-keyboard` replaced it. It reports the layout of whichever
  device last sent an input event, and sway registers **seven** keyboards here:
  the ThinkPad (gb), the waynergy virtual keyboard (us), and five that never
  type (Power_Button, Sleep_Button, Video_Bus, Intel_HID_events,
  ThinkPad_Extra_Buttons). A pseudo-keyboard event resolved to an empty layout
  and emptied the module. The script filters those out and only ever replaces
  the layout with another genuine one, so it cannot go blank. Short codes come
  from `/usr/share/X11/xkb/rules/evdev.xml`, not a hardcoded table.
- **`apt list --upgradable` and `apt-get --just-print upgrade` disagree.** The
  first reported 13 packages, the second 0, because a held-back coordinated set
  (pipewire) is listed as upgradable but produces no `Inst` line. The badge
  counted the second while its own click-popup listed the first, so the module
  was invisible while 13 updates waited. Both now read the same source - a
  badge that contradicts its own popup is worse than no badge.
- **The `privacy` module is pipewire-only.** i3status-rust used two drivers,
  `v4l` for the camera and `pipewire` for mic and screen-share; waybar's native
  module has no v4l equivalent. Most cameras route through pipewire, so this is
  probably not a loss, but **it has never been verified live** - it only
  appears when something is actually using the mic, camera or screen-share.
  The upside is that `cargo install i3status-rs --features pipewire` is no
  longer needed for it; that feature was the only reason a cargo-built binary
  had to be on `PATH`.

`.config/i3status-rust/config.toml` is now dead weight - nothing reads it. It
is kept because it is the rollback path, not because it runs. Note its
`temperature` block could not have been working: it asks for `chip = "*-isa-*"`
and lm-sensors is not installed. waybar reads
`/sys/devices/platform/coretemp.0/hwmon` directly instead - an absolute
platform path rather than `/sys/class/hwmon/hwmonN`, because the N moves
between boots.

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

The palette matters more since the bar gained click actions, because **waybar
cannot be driven from the keyboard at all** - it is a layer-shell surface with
keyboard interactivity off, so it never takes focus and has no tab order. Bar
clicks are a convenience for when a hand is already on the pointer; the palette
is the keyboard path, and it calls the same scripts so the two cannot diverge.
Four entries were added for bar actions that had no keyboard route: **Do not
disturb** (a real toggle, and the only one that predates the bar work - the
existing "Notifications" entry is `dunstctl history-pop`, a different thing),
**Calendar**, **Containers** and **Updates**. Do not disturb shows its current
state as `[on]`/`[off]` so the entry says what it will do, while keeping the
words "Do not disturb" in both labels so typing them always matches.

Everything is a small script in `~/bin` over `fuzzel --dmenu`, so it all looks
like the launcher instead of like four unrelated tools:

#### Which language, and why it is mostly shell

Shell for the glue, Python once a data structure is involved, compiled for
nothing here. That is not a preference, it is where each stops being the
obvious tool:

- **Shell** wins at running programs and joining them with pipes.
  `grim -g "$(slurp)" - | wl-copy` is a whole screenshot tool on one line, and
  nothing else expresses it more clearly.
- **Python** takes over the moment something has to be *parsed* - in practice,
  always `swaymsg -t get_tree` JSON. That is why `fuzzel-windows`, `sway-keys`,
  `waybar-keyboard` and `fuzzel-emoji` are Python, and why a handful of bash
  scripts embed a `python3 -c` block mid-pipeline.
- **Compiled** is what the tools themselves are - of the desktop programs
  installed here, 20 of 22 are C/C++/Rust/Go and only `udiskie` and `blueman`
  are Python. None of them is shell. But a compiled helper in a *dotfiles* repo
  means a build step and a binary to ship, and that has already gone wrong once
  here: the 24MB `i3status-rs` committed to `~/bin` was two versions stale and
  built without the feature it was needed for.

Startup cost, measured on this machine: `sh` 0.9ms, a compiled binary 1.4ms,
`bash` 1.8ms, `python3` 12.9ms, and 19ms once `json` is imported. Invisible for
anything a keypress triggers - fuzzel takes longer to draw - which is why the
palette can afford Python. It is not invisible for the `waybar-*` modules that
run every few seconds forever, which is why those stay in shell.

`fuzzel-menu` was ported from bash in 2026-09 on exactly that line. It had
grown to 26 entries held in two parallel lists - labels in an `entries=()`
array, actions in a `case` block - that had to be edited together, and matched
between them with suffix globs like `*"Files")`, so a future label ending in
the same words would have run the wrong thing. It is now one list of
`(label, action)` pairs dispatched by index. `fuzzel-menu --list` prints the
labels without opening anything, which is how the port was checked against the
bash version.

**That check was not enough, and the first port shipped with every entry
dead.** It matched fuzzel's output text back to the label list, and stripped
the output to lose the trailing newline - which also stripped the two leading
spaces every label has, so nothing ever matched and the failure was swallowed
silently. `--list` compares labels and never exercises selection, so it passed.
Now `fuzzel --index` returns a position and there is no text to match; the
dispatch path is tested by stubbing fuzzel to return each index in turn and
asserting the matching action fires, 26/26, plus Escape, out-of-range and the
`-1` fuzzel prints for typed text that matches nothing.

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
| `fuzzel-vpn` | work OpenVPN + Surfshark, with tunnel status, and the work VPN's log | the work profile needs `sudo` **and** prompts for user/pass (inline certs + `auth-user-pass`), so it opens a terminal rather than pretending a menu can do it - one that closes itself once connected (`vpn-work-connect`, below) |
| `sway-nightlight` | wlsunset toggle | a toggle, not an autostart: you want it off instantly when judging a colour. Coords via `WLSUNSET_LAT`/`WLSUNSET_LON` |
| `fuzzel-screenshot` | region/window/screen → clipboard or file, 5s delay, annotate | `PrtSc` is an awkward reach on the Glove80, so `$mod+Shift+P` is the keyboard-first route. Saves to `~/Pictures/Screenshots` and copies too |
| `fuzzel-media` | removable media: where it mounted, open, unmount **and** power off | udiskie runs `--no-tray`, so nothing else offered an eject affordance at all. Filters on `hotplug`+`type=part`, not the old `rm` bit, which misses USB enclosures - and that one condition also drops the internal nvme and ~39 snap loop devices. All via `udisksctl`, the layer udiskie itself drives, so the two agree and no root is needed. Unmount powers the disk off when it holds no other mount, which is what actually makes it safe to pull |
| `fuzzel-menu` | the palette itself | calls the above rather than reimplementing them |

**File manager:** `yazi`, in a foot window via `~/bin/yazi-term`, on
`$mod+Shift+e` and in the palette as **Files**. `$mod+e` was already the emoji
picker, and "e for explorer" keeps the pair on adjacent keys.

The closest thing to File Pilot that runs here, which was the brief. File
Pilot itself is Windows-only - Linux and macOS ports are on its roadmap but
explicitly deferred until Windows is solid - and nothing on Linux reproduces a
hand-written GPU-rendered GUI in a 2MB binary. yazi matches the parts that
matter day to day: instant start, async I/O so it streams thumbnails instead
of stalling on a big directory, real previews, tabs, vim keys, and bulk rename
into `$EDITOR`. Dolphin is the nearest GUI equivalent, at the cost of pulling
KDE libraries onto a sway session. Nautilus is not close on any axis - no dual
pane, no preview panel, weak keyboard coverage - and stays installed only
because the GTK file-chooser portal wants it.

Installed with **`cargo install --force yazi-build`**; it is not in the Ubuntu
26.04 archive. The snap exists and is published by the upstream author, but
strict confinement is the wrong shape for a file manager.

The obvious `cargo install yazi-fm yazi-cli` is what the older guides say and
it **fails**, by design: the crates' `build.rs` panics with "Due to Cargo's
limitations, the `yazi-fm` and `yazi-cli` crates on crates.io must be built
with `cargo install --force yazi-build`". `yazi-build` is a shim that installs
both. It needs `make` and `gcc`, and it breaks if `CARGO_TARGET_DIR` is set.

Image previews need a terminal with a graphics protocol, and both here have
one: foot does sixel, wezterm does the kitty protocol. `poppler-utils` is
already present for PDF previews. Not installed, so those previews degrade
rather than fail: `ffmpeg` (video thumbnails) and `7zip` (archive contents).

`~/.local/share/applications/yazi.desktop` exists mainly so the bar has an
icon to draw: waybar's `icon: true` resolves app_id against a desktop entry and
yazi ships none, so the module showed "Yazi: kelvin" with an empty icon slot.
Its filename has to match the `--app-id` the wrapper sets. Icon is the stock
`system-file-manager` from Yaru rather than a yazi logo, since yazi installs no
icon of its own. Same `Terminal=false` + wrapper shape as `btop.desktop`, for
the reason documented there, and adding it meant another `!` line in
`.gitignore` - the allowlist re-includes desktop entries one file at a time,
so a new one is invisible to git until it is named.

Unlike `btop-term` this one **tiles** - no floating rule and no
`--window-size-chars`. A file manager is worked alongside rather than glanced
at and dismissed, and sway sizes tiled windows itself, so the flag would be
inert. It does reuse btop-term's single-instance guard: yazi opens tabs with
`t`, so a second window is nearly always an accident.

Volume is **scroll-wheel on the waybar `pulseaudio` module** (`scroll-step`
there, 5%), not a menu entry: re-opening fuzzel per 5% step flashed the window.
The i3status-rust equivalent was `step_width`.

`$mod+t` (`dmenu_run` under XWayland) was **dropped in 2026-09**. It enumerated
every executable on `PATH` - about 2400 here - against fuzzel's ~140 desktop
entries, and the difference was almost entirely noise: CLI tools, one-off setup
scripts like `enable-hibernate.sh`, and the `waybar-*` module backends, which
are meant to be called by the bar and misbehave when run by hand
(`waybar-keyboard` streams JSON until killed). An audit found nothing on it
that deserved a `.desktop` entry: of the genuinely user-facing GUI programs
only `qalc`, `wlogout` and `gsimplecal` lack one, and all three are already on
a keybind, the bar or the palette. 26 of the 44 scripts in `~/bin` are reachable
without it; the other 18 are CLI or internal.

All fuzzel invocations pass `--no-exit-on-keyboard-focus-loss`. Sway defaults to
`focus_follows_mouse`, so without it moving the pointer towards the menu focuses
whatever is underneath and fuzzel exits before you arrive.

Clipboard history is cliphist, fed by **two** `wl-paste --watch` instances from
the sway config - one `--type text`, one `--type image`. Two are needed because
the filter is per-watcher: a single unfiltered `wl-paste` stores the
`text/plain` offer that accompanies an image copy rather than the image itself.

Images were excluded until 2026-09, on the reasonable grounds that a screenshot
can contain anything that was on screen. The trade was worse than it looked:
**the live clipboard has always carried images fine** - a copied PNG pastes
byte-identically into anything - but nothing retained it, so an image survived
only until the next copy and pasting a screenshot somewhere meant retaking it.
Both watchers share one 750-item store; `fuzzel-clipboard --wipe` clears it.

`$mod+u` runs `fuzzel-clipboard --images`, which filters the list to entries
cliphist renders as `[[ binary data 47 KiB png 1920x60 ]]`. It is a separate
key from `$mod+Shift+v` because fuzzel cannot draw a thumbnail in a dmenu list,
so an image is effectively invisible among text entries; the size and
dimensions in that line, newest first, are what you pick by.

`Ctrl+$mod+u` runs `~/bin/clip-image-path`, which is the answer to "how do I
give Claude Code a screenshot". Claude Code takes images as file paths, and its
Ctrl+V clipboard-image handler is guarded to macOS
([claude-code#48402](https://github.com/anthropics/claude-code/issues/48402)),
so on Linux pasting an image into it does nothing whatsoever - no error, no
placeholder. The script writes the clipboard image to `~/Pictures/Clipboard/`
and then puts **the path** on the clipboard as text, so an ordinary terminal
paste works. `--pick` (the palette entry) chooses from cliphist's image history
first, for an image copied a while back. The extension comes from the actual
MIME type rather than assuming png, since a browser copy is often jpeg or webp.

Copies made on the Windows machine arrive here too, via waynergy - **text
only**. The synergy protocol it speaks does not carry images, so an image
copied over there cannot be pasted here regardless of this.

Note the watchers are `exec`, not `exec_always`, so adding one does **not**
take effect on `swaymsg reload` - it needs a fresh session, or starting the
watcher by hand for the current one.

**Touchpad:** sway applies no touchpad defaults whatsoever - no tap-to-click, no
natural scrolling, no disable-while-typing - so the config sets them under
`input type:touchpad`. Device type rather than id so it survives new hardware;
safe here because waynergy's virtual device registers as a pointer, not a
touchpad (unlike `type:keyboard`, which would catch its virtual keyboard).
`natural_scroll enabled` is the line to flip if the scroll direction feels wrong.

Other bindings added: `$mod+Tab` window switcher, `$mod+e` emoji,
`$mod+Shift+p` screenshot menu, `$mod+t` / `$mod+Shift+t` scratchpad show/move.
`$mod+n` / `$mod+Shift+n` re-show last notification / clear all (dunst keeps a
history; unbound, a missed notification is just gone). `$mod+Shift+z` pins a
floating window across workspaces.
To take a window back **out** of the scratchpad there is no dedicated command:
summon it with `$mod+t`, then `$mod+Shift+BackSpace` (floating toggle) tiles it
into the current workspace.

**Key positions assume Colemak Mod-DH**, which lives in the Glove80's own
firmware - sway sees only the post-remap keysym, arriving as a US layout on
`wlr_virtual_keyboard_v1` over waynergy. The `xkb_layout gb` line applies to
the built-in laptop keyboard alone, which is not the one being optimised for.
Under that layout the left hand is `q w f p b` / `a r s t g` / `z x c d v` and
the right is `j l u y` / `m n e i o` / `k h`; the whole right hand is an
awkward reach while `$mod` is held.

That is why the scratchpad moved from `u` (right hand, top row) to `t` in
2026-09: `t` is left-hand home row, index finger, and was the last good free
key there. Sticky toggle gave up `$mod+Shift+t` for it and went to
`$mod+Shift+z`, being rare enough for a pinky. `$mod+u` / `$mod+Shift+u` are
kept as aliases - muscle memory outlives a config change. Scratchpad is not on
the i3 convention `$mod+minus` because `$mod+Shift+minus` is already
volume-down.

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

Its `[key-bindings]` section makes **Up/Down wrap around** - Up on the first
entry jumps to the last - which is the shortest route to the bottom of a long
menu. fuzzel has the wrapping actions already, just bound to Shift+Tab/Tab
rather than the arrows, so this rebinds `prev-with-wrap`/`next-with-wrap` onto
Up/Down. The non-wrapping defaults must be released first with `prev=none` /
`next=none`: one key bound to two actions is a hard config error.

Tab is deliberately left alone. `man 5 fuzzel.ini` documents it as the default
for `next-with-wrap`, but in fuzzel 1.12 it is `execute-or-next`, and binding
it breaks dmenu-style completion. **`fuzzel --check-config`** catches exactly
this without launching anything, and is worth running after any edit here:

```
[key-bindings].next-with-wrap: Tab already mapped to 'execute-or-next'
```

**Terminal:** wezterm is the everyday one; `foot` is the throwaway used by the
palette (btop), the Wi-Fi picker (`nmtui`) and the VPN menu. Its default is
`monospace:size=8`, unreadable on a 1200p panel and worse on 4K, so
`~/.config/foot/foot.ini` matches the bar font instead and sets
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

**The work VPN tidies itself away.** `fuzzel-vpn` opens a terminal running
`~/bin/vpn-work-connect`, which starts openvpn with `--daemon --log-append
~/.local/state/vpn-work.log`. openvpn asks for the sudo password and the VPN
credentials in that terminal - it queries passwords before daemonising - then
detaches and writes its own log. The window follows the log and **closes itself**
on `Initialization Sequence Completed`; on `AUTH_FAILED` or a fatal error, or
after 60s without a verdict, it stays open with the reason on screen.
**Show work VPN log** in the menu follows the file afterwards, and it goes on
recording drops and reconnects with no window open. Disconnect is the menu
entry, as before: it sends SIGINT, the signal openvpn tears routes down on.

This needs the (private, out-of-repo) work script to forward `"$@"` to openvpn,
which it does since 2026-09. The log is created by `vpn-work-connect` before
openvpn starts, so it is the user's own `0600` file that root appends to - left
to openvpn it would be root-owned and need sudo to read.

How it got here matters, because the obvious fixes fail:

- The window used to run openvpn in the foreground, and its comment claimed
  closing it dropped the tunnel. **It did not**: sudo was reparented to PID 1
  and `tun0` stayed up. Closing the window was the tidy-away all along - it
  just lost the output.
- Keeping that output by wrapping the launch in `script -f` was tried and
  **breaks the tunnel**: `script` kills its child when its own terminal closes,
  and cannot outlive the terminal even with SIGHUP ignored. Checked with a
  stand-in that survives SIGHUP the way openvpn does: alive with a plain
  terminal, dead under `script`.
- `--daemon` sidesteps both, because nothing depends on the terminal at all.

**Background apps - no XDG autostart:** nothing in this session processes
`~/.config/autostart/` - that needs `dex` or a full desktop session, and sway
launches neither. Anything that must start with the session therefore needs an
`exec` line in the sway config, and a `.desktop` file there is silently inert.

This bit twice, quietly. Tresorit and Surfshark each shipped an autostart
entry and neither had ever run: Tresorit last started **2026-09-08**, and the
journal logged `sh: 1: tresorit: not found` at every session start because the
sway `exec` used a bare name and the binary is not on `PATH`. Surfshark had no
`exec` at all. That is also why the VPN indicator above had never shown
anything - it detects the tunnel correctly, but the client was never running
to make one.

Both `.desktop` files were deleted, along with `~/.config/autostart/`, so that
each app has exactly one launch path:

```
exec --no-startup-id ~/.local/share/tresorit/tresorit --hidden
exec --no-startup-id /opt/Surfshark/surfshark
```

**Surfshark puts its entry back.** `~/.config/autostart/surfshark.desktop`
reappeared the next time the client ran, so the directory exists again and
deleting it is not a fix that holds. It is inert here - nothing in this session
reads that directory - so the duplicate launch path is theoretical rather than
real, and the `exec` line above stays the one that matters. Worth knowing
before concluding the directory was deleted by mistake.

Note `exec`, not `exec_always`: these run once at session start and are not
restarted by `swaymsg reload`. Worth remembering when testing - a reload will
never reveal a broken one, which is part of why this went unnoticed for so
long. `journalctl --user -b | grep "not found"` does reveal it.

**Removable media:** `udiskie --automount --notify --no-tray` from the sway
config. GNOME did this through gvfs; under sway nothing does, so a USB stick
would simply never appear.

`--no-tray` is deliberate, but it means automount is the *whole* interaction:
the stick mounts at `/run/media/$USER/<LABEL>`, dunst says so once, and after
that there is no way to find it again or eject it. `~/bin/fuzzel-media`
(palette: **Removable media**) is that missing half - it lists what is plugged
in with mount state, opens it, and unmounts *and powers off* the disk, which a
bare `umount` does not do and is what makes it safe to physically pull.

### SwayFX - tried, does NOT work here (2026-09)

[SwayFX](https://github.com/WillPower3309/swayfx) is a sway fork adding rounded
corners, shadows, blur and dim-inactive, with the same config syntax and IPC.

**It builds and runs but renders nothing.** Window decorations and titlebars
draw correctly; client buffers stay black. Unusable. Left here because
everything needed for a retry is in place - do not assume it works.

What was established, by controlled comparison rather than log-reading:

| Nested, identical `foot` command | Result |
| --- | --- |
| stock sway 1.11 | renders correctly |
| SwayFX 0.5.3, effects enabled | black |
| SwayFX 0.5.3, no effects at all | black |

So it is **not** the effects, and not the renderer. Two theories that looked
right and were not: `WLR_RENDERER=gles2` (SceneFX is GLES2-only and Vulkan ICDs
are installed, so wlroots may prefer Vulkan - forcing it changed nothing) and
`corner_radius`/`default_dim_inactive` (they do produce real
`pixman_region32_union_rect: Invalid rectangle passed` spam, but black windows
happen without them too).

Best remaining theory, untested: an ABI mismatch between Ubuntu's wlroots
**0.19.2** point release and what SceneFX 0.4.1 expects - it compiles, links and
starts cleanly, then composites nothing.

#### How to retry

The version pairing is the crux. SceneFX and SwayFX master both target wlroots
0.20; Ubuntu 26.04 ships 0.19.2, which is what sway 1.11 is built against.
`~/bin/build-swayfx.sh` pins the wlroots-0.19 pair (SceneFX 0.4.1 / SwayFX
0.5.3) in two variables at the top.

- **When Ubuntu ships wlroots 0.20**: bump those to SceneFX 0.5 / SwayFX 0.6,
  rebuild, reinstall the session entry. Most likely to just work.
- **Sooner**: build wlroots 0.20 into `~/.local` too, then SceneFX 0.5 and
  SwayFX 0.6 against it. Self-contained, but needs `LD_LIBRARY_PATH` care so it
  does not pick up the system wlroots. Judged a poor trade for rounded corners.

Retest in 90 seconds without logging out - nested, and *look* at it rather than
reading logs:

```
export LD_LIBRARY_PATH="$HOME/.local/lib/x86_64-linux-gnu"
printf 'exec foot -e sh -c "echo RENDER-TEST; sleep 30"\n' > /tmp/fx.conf
( timeout 14 ~/.local/bin/swayfx -c /tmp/fx.conf & ) ; sleep 7; grim /tmp/fx.png
```

If `RENDER-TEST` is visible in the nested window, it works.

#### What is already in place

- `~/bin/build-swayfx.sh` - builds SceneFX then SwayFX into `~/.local`,
  pinned. Renames the binary to `swayfx` and deletes the `swaymsg`/`swaybar`/
  `swaynag`/`swaybg` it installs, because `~/.local/bin` precedes `/usr/bin` on
  PATH and those shadow the packaged tools for every shell - `sway --validate`
  broke exactly that way.
- `~/bin/swayfx-session` - session wrapper. Sets `LD_LIBRARY_PATH` (SceneFX
  lands in `~/.local/lib/x86_64-linux-gnu`, not on the loader path), points at
  `config.fx`, and logs to `/tmp/swayfx-session.log` **first**. GDM session
  failures often leave nothing in the journal at all; that log was the only
  reason two of these failures were diagnosable.
- `~/.config/sway/config.fx` - effects, `include`ing the main config. They
  cannot live in the main config: stock sway rejects all 11 and then refuses to
  load, leaving no session. Note `animation_duration_ms` is in SwayFX master's
  docs but not in 0.5.3, and an unknown directive is fatal.
- Session entry (removed): `Exec` must point **outside** `$HOME` - GDM's
  greeter runs as user `gdm` and cannot traverse `/home/kelvin` (0750), so an
  `Exec` under home makes the session vanish with no logs. The working shape was
  a two-line shim in `/usr/local/bin` exec'ing `~/bin/swayfx-session`, so
  editing the tracked script never leaves the deployed copy stale.

Build deps beyond the sway ones:

```
sudo apt install libwlroots-0.19-dev libpixman-1-dev libdrm-dev libinput-dev \
    libjson-c-dev libpcre2-dev libevdev-dev libcairo2-dev libpango1.0-dev \
    libgbm-dev libseat-dev libxcb1-dev scdoc
```

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
