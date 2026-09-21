# Keymap

Sway bindings on `gigabox`, grouped by what you are trying to do rather than by
modifier. `$mod` = `Mod4` = `Super`.

Source of truth is `~/.config/sway/config`; `~/bin/sway-keys` parses it and
pipes the lot through fuzzel (`--list` prints instead), so that can never go
stale. This file is the readable version.

## Start here

**`Super` + `Backspace`** opens the command palette. Everything below is
reachable from it, so it is the only shortcut worth memorising - the rest are
accelerators. Type to filter, Enter to run, Escape to dismiss.

It contains: Wi-Fi · Audio output · Clipboard history · Removable media ·
Files · Bluetooth · VPN · Windows · Emoji / characters · Power profile ·
System monitor · Calculator · Record screen · Colour picker · Night light ·
Notifications · Do not disturb · Calendar · Containers · Updates ·
Screenshot · Display layout · Keybindings · Lock · Power menu.

On `Backspace` rather than `Space` because it is the easier reach on the
Glove80. `focus mode_toggle` took `Super`+`Space` in exchange, which is sway's
own default for it.

## Find and summon

| Key | Does |
| --- | --- |
| `Super`+`Backspace` | Command palette |
| `Super`+`Tab` | Window switcher - every window, every workspace |
| `Super`+`Shift`+`V` | Clipboard history (text) |
| `Super`+`U` | Clipboard history, images only |
| `Ctrl`+`Super`+`U` | Clipboard image -> file, path copied (for Claude Code) |
| `Super`+`E` | Emoji and symbols |
| `Super`+`Shift`+`E` | File manager (yazi, in a foot window) |
| `Super`+`N` | Re-show last notification |
| `Super`+`Shift`+`N` | Clear all notifications |
| `Super`+`D` | App launcher (fuzzel) |
| `Super`+`G` | Terminal (wezterm) |

## Scratchpad

| Key | Does |
| --- | --- |
| `Super`+`T` | Show / hide |
| `Super`+`Shift`+`T` | Send focused window there |
| `Super`+`Shift`+`Backspace` | **Take it back out** |

`Super`+`Shift`+`U` still sends a window there. `Super`+`U` no longer summons
it - that key is the image clipboard now.

Sway has no "remove from scratchpad" command. Summon the window first, then
float-toggle tiles it into the current workspace.

Not the i3 convention `$mod`+`minus`: `$mod`+`Shift`+`minus` is already
volume-down here. `T` is the left-hand home-row index key under the Glove80's
Colemak Mod-DH firmware - the best position on the board - and the scratchpad
was the most-used thing sitting on the right hand, which is an awkward reach
while `Super` is held.

## Windows and layout

| Key | Does |
| --- | --- |
| `Super`+`Shift`+`Delete` | Close window |
| `Super`+`P` | Fullscreen |
| `Super`+`R` / `W` / `B` | Stacking / tabbed / toggle split |
| `Super`+`H` / `V` | Split horizontal / vertical |
| `Super`+`Shift`+`Backspace` | Float toggle |
| `Super`+`Shift`+`Z` | Sticky - pin a floating window across workspaces |
| `Super`+`Space` | Focus tiling <-> floating |
| `Super`+`J` | Resize mode (`n` `e` `i` `o` or arrows; Enter/Escape to leave) |
| `Super`+`S` / `F` | Focus down / up (arrows work too) |
| `Super`+`Shift`+`S` / `F` | Move window down / up |
| `Super`+`A` / `C` | Focus parent / child |

## Workspaces

20 of them, which is why `Super`+`Tab` exists.

| Key | Does |
| --- | --- |
| `Super`+`1`…`0` | Workspace 1-10 |
| `Ctrl`+`Super`+`1`…`0` | Workspace 11-20 |
| `Super`+`Shift`+`<n>` | Move window to that workspace |
| `Super`+`Home` / `End` | Move workspace to left / right output |
| `Ctrl`+`Super`+`S` / `F` | Move workspace to output up / down |

## Sound, media, brightness

| Key | Does |
| --- | --- |
| `XF86AudioRaise/LowerVolume` | Volume ±5% |
| `Super`+`Shift`+`+` / `-` | Volume ±3% |
| `Super`+`Shift`+`M` | Mute |
| `XF86AudioPlay` / `Next` / `Prev` | Media control (playerctl) |
| `XF86MonBrightnessUp` / `Down` | Backlight ±5% |

Volume is also **scroll-wheel on the bar's sound module** - instant, nothing
drawn. That is the intended route; a menu was tried and flashed on every step.

## Screen, session, displays

| Key | Does |
| --- | --- |
| `Super`+`Shift`+`P` | Screenshot menu |
| `PrtSc` | Whole screen to clipboard |
| `Shift`+`PrtSc` | Region to clipboard |
| `Ctrl`+`Alt`+`L` | Lock |
| `Ctrl`+`Shift`+`Alt`+`L` | Lock and suspend |
| `Super`+`Shift`+`X` | Power menu (wlogout) |
| `Super`+`Shift`+`C` | Reload sway |
| `Super`+`Y` | Three monitors |
| `Super`+`Shift`+`Y` | Dual |
| `Ctrl`+`Super`+`Y` | Laptop only |

The screenshot menu offers region / window / screen, each to clipboard or file,
plus a 5s delay and annotate. `PrtSc` is an awkward reach on the Glove80, hence
`Shift`+`P` for "print".

i3's `$mod`+`Shift`+`Z` ("restart in place") is **not** ported. Sway has no
equivalent - the compositor is the display server, so re-executing it would
tear down every client - and pointing it at `reload` only duplicated
`$mod`+`Shift`+`C`. Use `Super`+`Shift`+`C`.

## The status bar is clickable

- **Sound** - scroll to change volume; left-click picks the output device,
  right-click opens the per-app mixer.
- **Network** - left-click for the Wi-Fi picker, right-click for the full
  connection editor.
- **CPU, load, memory, temperature, disk** - any of them opens btop, and they
  share one window rather than stacking five.
- **Battery** - power profile picker.
- **Docker** - running container count; click lists them.
- **Updates** - pending apt packages; click lists them.
- **Bell** - do not disturb, a real toggle.
- **Clock** - opens the calendar.
- **Power icon** - the same wlogout grid as `Super`+`Shift`+`X`.

The bar cannot be driven from the keyboard at all - it is a layer-shell surface
that never takes focus - so every one of these also has a palette entry.

## Behaviour worth knowing

- **Pasting an image into Claude Code** needs a *path*, not a paste: its
  Ctrl+V clipboard-image handler is macOS-only, so on Linux pasting an image
  into it does nothing. `Ctrl`+`Super`+`U` writes the clipboard image to
  `~/Pictures/Clipboard/` and puts that path on the clipboard as text, so an
  ordinary paste then works. The palette entry (**Image to file**) does the
  same but lets you pick an older image out of the history first.
- **Clipboard history** starts collecting at login; it cannot show what you
  copied before that. Text **and images** since 2026-09 - `Super`+`U` lists
  just the images, because a screenshot is impossible to spot in the mixed
  list (no thumbnail, just `[[ binary data 47 KiB png 1920x60 ]]`). Copies made
  on the Windows machine arrive here too, over waynergy, though that link
  carries text only. `fuzzel-clipboard --wipe` clears everything.
- **Emoji picker** copies *and* types the character. Typing alone fails in apps
  that ignore synthetic input; copying alone would need an extra paste.
- **Window switcher** focuses by `con_id`, not title - titles repeat and change
  while you are looking at them.
- **Screenshots** saved to file land in `~/Pictures/Screenshots` with a
  timestamp, and go on the clipboard as well.
- **Closing the lid** with an external monitor attached drops the internal panel
  and keeps the session; on the laptop alone it locks, then suspends.
- **Power profile** is performance / balanced / power-saver. The main battery
  lever, because this firmware offers only s2idle - there is no deep S3.
- **USB sticks** mount automatically with a notification.
- **Lost a shortcut?** Palette -> Keybindings, or `sway-keys --list`.

Changes to `~/.config/sway/config` need `Super`+`Shift`+`C` to take effect.
