dotfiles
========

Sublime Text Setup on Windows
------------------------------

The configuration files for sublime text are checked out to the linux standard location, so we must make a hard folder link (junction) on Windows.

```
git clone https://github.com/enerqi/dotfiles.git %USERPROFILE%/dotfiles
cd dotfiles && mv .config %USERPROFILE%

cd "%USERPROFILE%/AppData/Roaming/Sublime Text 3"
rmdir /S /Q "%USERPROFILE%/AppData/Roaming/Sublime Text 3/Packages"
rmdir /S /Q "%USERPROFILE%/AppData/Roaming/Sublime Text 3/Installed Packages"

mklink /J Packages "%USERPROFILE%/.config/sublime-text-3/Packages"
mklink /J "Installed Packages" "%USERPROFILE%/.config/sublime-text-3/Installed Packages"
```

If sublime-text was installed and used earlier you may need to nuke the session file:

`del %USERPROFILE%/AppData/Roaming/Sublime Text 3/Local/*.session`
