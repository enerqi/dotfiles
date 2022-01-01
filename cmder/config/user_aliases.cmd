;= @echo off
;= rem Call DOSKEY and use this file as the macrofile
;= %SystemRoot%\system32\doskey /listsize=1000 /macrofile=%0%
;= rem In batch mode, jump to the end of the file
;= goto:eof
;= Add aliases below here
;= https://github.com/cmderdev/cmder/wiki/Cmder-Aliases
e.=explorer .
gl=git log --oneline --all --graph --decorate  $*
ls=ls --show-control-chars -F --color $*
cd=zcd $*
pwd=cd
clear=cls
history=cat %CMDER_ROOT%\config\.history
unalias=alias /d $1
vi=vim $*
cmderr=cd /d "%CMDER_ROOT%"
gst=git status $*
l=ls --show-control-chars -F --color -Alh $*
lt=ls -lstr --color=auto
gfm=git pull $*
udesql=pclip | grep -v === | column -t
duplicateLines=sed "/^$/d" $1 | sort | uniq -d
pkt=.paket\paket.exe $* 
reload=%CMDER_ROOT%\vendor\init.bat