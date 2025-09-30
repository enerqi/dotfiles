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

- Optional suggested other binaries include [ripgrep - rg](https://crates.io/crates/ripgrep#installation),
  [fd-find - fd](https://crates.io/crates/fd-find#installation) and [exa](https://crates.io/crates/exa#installation).
  All buildable with `cargo install ...`.

Then add local machine specific definitions as desired:

```
.zshrc.local
.profile  (graphical login environment variables)
.xinitrc/.xsession (running graphical programs)
.zprofile.local (login shells - rarely needed)
```

- For programs started by the desktop manager and not the interactive shell process hierarachy, such as sublime-text, use `~/.profile` to setup the environment variables. `.xsessionrc` maybe a better approved way to do this.
- `.zprofile` / `~/.zprofile.local`  shouldn't change the key bindings, aliases, functions or shell options but could set the PATH for non-interactive or login commandline programs.
- `.xinitrc` (startx) / `.xsession` (xdm) run window manager independent programs after graphical login. Window manager specific scripts could also be used.

## Assorted Development Tools

Some mentioned above and below.

- apt install `git zsh build-essential libsensors-dev libssl-dev cmake clang pkg-config postgresql-client`
  - `git config --global credential.helper cache`
- apt install `openvpn feh fonts-font-awesome`
- [LLVM install script for Apt](https://apt.llvm.org/)
- libs for compiling more things e.g apt install `libsdl2-dev libpulse-dev libnotmuch_dev libssl-dev libpipewire-0.3-dev`
- `gsimplecal`
- [mise](https://mise.jdx.dev/getting-started.html) for python/node etc. version management on Linux
  - `mise use -g node@lts` etc.
- [fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#using-git) fuzzy finder from git or os packages
- [sublime text / sublime merge](https://www.sublimetext.com/docs/linux_repositories.html) apt packages
- docker binaries - apt install `docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
  - [permission issue]([permission](https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue)
  - apt install `python3-setuptools` if missing distutils problem with `docker compose` commands
- [rustup](https://rustup.rs/)
  - `cargo install cargo-binstall`
  - `cargo binstall -y starship` + `zoxide` + `bat`
- install some sync service, e.g. [tresorit](https://tresorit.com/)
- `firefox` sync for custom settings and extensions
- `chrome` plus `ublock origin` extension for commonly used browser dev tools

## Window Manager Setup

- install [i3 window manager](https://i3wm.org/downloads/) >= *v4.20*
  - `i3wm i3lock-fancy i3blocks` (not `i3` meta package as we want the rust status bar)
  - a copy of `i3status-rs` is already in `~/bin` but a recent version could be compiled with rust (`cargo install i3status-rs; cp ~/.cargo/bin/i3status-rs ~/bin`)
- install [wezterm](https://wezfurlong.org/wezterm/index.html)
- install nerd fonts by tweaking/running [`~/bin/fetch-fonts.sh`](./bin/fetch-fonts.sh)
  - optional for some things as wezterm bundles nerd fonts, but that script includes many fonts
  - `fc-list` to check font names used in `.config/i3/config` and `.config/alacritty/alacritty.toml` or with wezterm
    `wezterm ls-fonts --list-system`
- `apt install compton pulseaudio pavucontrol` (compositor, sound panel control, i3 volume control etc.)


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
