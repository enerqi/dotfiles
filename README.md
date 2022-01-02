# dotfiles

## ZSH Setup

### With these dotfiles

- Install `zsh` with your package manager
- Install [zgenom](https://github.com/jandamm/zgenom) zsh plugin manager:

```
git clone https://github.com/jandamm/zgenom.git "${HOME}/.zgenom"
```

- Install [starship](https://starship.rs/guide/#%F0%9F%9A%80-installation) shell prompt tool
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
- `.xinitrc` (startx) / `.xsession` (xdm) run window manager independent programs after graphical login. Window manager specific scripts such as `~/.i3/config` could also be used.

## Window Manager Setup

- install [i3 window manager](https://i3wm.org/downloads/)
- install v0.9+ of `alacritty` terminal manager (i.e. with rust `cargo install alacritty`)
- install nerd fonts by tweaking/running [`~/bin/fetch-fonts.sh`](./bin/fetch-fonts.sh)
- a copy of `i3status-rs` is already in `~/bin` but a recent version could be compiled with rust (`cargo install i3status-rs; cp ~/.cargo/bin/i3status-rs ~/bin`)

## Sublime Text Setup

With a fresh sublime install:
- install package control from the sublime command pallette
- install the sync settings package and sync everything using the private gist access token and gist id from keepass.

This is easier than the earlier approach of syncing everything through this repository and then having to create a
hard folder link (junction) on windows so that the windows/linux file layouts were similar. It's still convenient to
create a hard link for the keymap files as we want the windows/linux keymaps to be the same.

```
cd "%USERPROFILE%/AppData/Roaming/Sublime Text 3/Packages/User"
del "Default (Windows).sublime-keymap"
mklink /H "Default (Windows).sublime-keymap" "Default (Linux).sublime-keymap"
```
