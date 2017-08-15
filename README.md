# dotfiles

## ZSH Setup

### With these dotfiles
```
git clone --recursive https://github.com/enerqi/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
```
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


### ZSH Prezto Only Setup
Follow setup steps in [https://github.com/enerqi/prezto](enerqi-prezto) and ignore these dotfiles.


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
