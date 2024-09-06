@ECHO OFF
SETLOCAL
SET FZF_DEFAULT_COMMAND=fd --type f
rem Fix fzf not working on Windows
SET TERM=
fzf %*
ENDLOCAL
