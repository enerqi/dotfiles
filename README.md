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
an absolute path in the sway config - see [DESKTOP.md](./DESKTOP.md).

- `.xinitrc` (startx) / `.xsession` (xdm) run window manager independent programs after graphical login. X11 only; nothing sources them under Wayland.

## NuShell Setup

- set `XDG_CONFIG_HOME` if on Windows to `C:/Users/<you>/.config`

## WezTerm Terminal Setup
- install [wezterm](https://wezfurlong.org/wezterm/index.html) (recent nightly as of early 2026 for best experience)
- install nerd fonts by tweaking/running [`~/bin/fetch-fonts.sh`](./bin/fetch-fonts.sh)
  - optional for some things as wezterm bundles nerd fonts, but that script includes many fonts
  - `fc-list` to check font names used in `.config/i3/config` and `.config/alacritty/alacritty.toml` or with wezterm
    `wezterm ls-fonts --list-system`

## Desktop / Window Manager

Sway (Wayland) on Ubuntu 26.04, which offers it as a session alongside GNOME.
Full detail and the reasoning behind each choice: **[DESKTOP.md](./DESKTOP.md)**.
Keyboard reference: **[KEYMAP.md](./KEYMAP.md)**.

```sh
apt install sway swayidle swaybg swaylock foot fuzzel waybar dunst \
            wl-clipboard grim slurp udiskie wlogout gsimplecal \
            brightnessctl playerctl pulseaudio-utils kanshi
cargo install --force yazi-build   # file manager; DESKTOP.md says why not `cargo install yazi-fm`
```

That is the minimum for the keybindings to all work; DESKTOP.md has the full
list, including the pickers' extras (cliphist, blueman, qalc, wf-recorder,
wlsunset, hyprpicker, wtype).

Log out and pick **Sway** on the login screen. Nothing in `~/.config/autostart/`
runs in this session, so anything that must start with it needs an `exec` line
in `~/.config/sway/config`.

| | |
| --- | --- |
| **`Super`+`Backspace`** | command palette - everything is reachable from here, the rest are accelerators |
| `Super`+`G` | terminal (wezterm) |
| `Super`+`d` | app launcher |
| `Super`+`Shift`+`e` | file manager (yazi) |
| `Super`+`Shift`+`x` | power menu |

What is where:

| path | |
| --- | --- |
| `~/.config/sway/config` | the window manager, and every `exec` that starts with the session |
| `~/.config/waybar/` | the bar: `config.jsonc` is structure, `style.css` is appearance |
| `~/bin/fuzzel-*` | the palette and its pickers - Wi-Fi, audio, VPN, clipboard, screenshots |
| `~/bin/waybar-*` | the bar modules that are not native - docker, VPN, DND, apt, keyboard |
| `~/bin/sway-*` | lock, keybinding help, night light, outputs |

Two things worth knowing before editing any of it:

- `default_border` and `gaps` apply to **newly created** windows and workspaces.
  A `swaymsg reload` looks like it did nothing; a fresh login is correct.
- `~/.config/i3status-rust/` and the commented `bar {}` block in the sway config
  are the rollback to swaybar. They are kept on purpose and nothing reads them.

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
