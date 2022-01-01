@ECHO OFF
rem ridiculous language - setting var from stdout of cmd
FOR /f "tokens=*" %%i in ('zoxide query -i --') do (
    set CD_DIR=%%i
)
zoxide add %CD_DIR%
cd %CD_DIR%
