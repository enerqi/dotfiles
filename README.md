dotfiles
========

ZSH Setup with these Dotfiles
----------------------------------------------
```
git clone --recursive https://github.com/enerqi/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
```
Then add local machine specific definitions as desired:
```
.zshrc.local
.zprofile.local
```
zprofile shouldn't change the key bindings, aliases, functions or shell options but could set the PATH for non-interactive or login GUI programs such as sublime-text that don't take the path from zshrc.

ZSH Prezto Only Setup
----------------------------
Follow setup steps in [https://github.com/enerqi/prezto](enerqi-prezto) and ignore these dotfiles.

Sublime Text Setup on Windows
------------------------------

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

The keymap files are different for windows and linux but we can hard link from the windows file to the linux one:
```
cd "%USERPROFILE%/AppData/Roaming/Sublime Text 3/Packages/User"
del "Default (Windows).sublime-keymap"
mklink /H "Default (Windows).sublime-keymap" "Default (Linux).sublime-keymap"
```

Haskell Setup to Support Sublime
---------------------------------

```
cabal install cabal-install
cabal install aeson [codex] haskell-src-exts ghc-mod stylish-haskell haskell-docs hasktags hdevtools hdocs [--constraint=haddock==2.13.2.1]
```

Codex might not build with GHC 7.8. The constraint on haddock maybe needed with GHC 7.6.
