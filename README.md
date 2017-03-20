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

- For programs started by the desktop manager and not the interactive shell process hierarachy, such as sublime-text, use `~/.profile` to setup the environment variables.
- `zprofile` / `~/.zprofile.local`  shouldn't change the key bindings, aliases, functions or shell options but could set the PATH for non-interactive or login commandline programs.
- `xinitrc` (startx) / `xsession` (xdm) run window manager independent programs after graphical login. Window manager specific scripts such as `~/.i3/config` could also be used.


### ZSH Prezto Only Setup
Follow setup steps in [https://github.com/enerqi/prezto](enerqi-prezto) and ignore these dotfiles.


## Sublime Text Setup on Windows

The configuration files for sublime text are checked out to the linux standard location, so we must make a hard folder link (junction) on Windows.

```
git clone https://github.com/enerqi/dotfiles.git %USERPROFILE%/dotfiles
cd dotfiles
```
Move everything to %USERPROFILE% `mv * %USERPROFILE`.
```
cd "%USERPROFILE%/AppData/Roaming/Sublime Text 3"
rmdir /S /Q "%USERPROFILE%/AppData/Roaming/Sublime Text 3/Packages"
rmdir /S /Q "%USERPROFILE%/AppData/Roaming/Sublime Text 3/Installed Packages"

mklink /J Packages "%USERPROFILE%/.config/sublime-text-3/Packages"
mklink /J "Installed Packages" "%USERPROFILE%/.config/sublime-text-3/Installed Packages"
```

If sublime-text was installed and used earlier you may need to nuke the session file:

`del %USERPROFILE%/AppData/Roaming/Sublime Text 3/Local/*.session`

The keymap files are different for windows and linux but we can hard link from the windows file to the linux one. Keeping them in sync manually is not so difficult as well.
```
cd "%USERPROFILE%/AppData/Roaming/Sublime Text 3/Packages/User"
del "Default (Windows).sublime-keymap"
mklink /H "Default (Windows).sublime-keymap" "Default (Linux).sublime-keymap"
```
