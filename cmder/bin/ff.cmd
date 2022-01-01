@ECHO OFF
SETLOCAL
rem Fix fzf not working on Windows
SET TERM=
fzf %*
ENDLOCAL
