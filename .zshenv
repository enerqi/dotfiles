# Defines environment variables.

# .zshenv is read by every zsh invocation (login or not, interactive or not),
# but zsh's own startup sequence only sources .zprofile for login shells. For
# this terminal (WezTerm) that's moot -- every pane is spawned as a login
# shell -- but other launchers (VS Code's integrated terminal, ssh running a
# remote command, cron, systemd units, `#!/usr/bin/env zsh` scripts) start
# non-login shells, where .zprofile's PATH/EDITOR/LESS setup would otherwise
# never run. Source it manually here, once per outermost shell (SHLVL -eq 1
# guards against redoing it in shells nested inside an already-initialized
# one; ! -o LOGIN avoids double-sourcing where zsh already does this itself).
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
. "$HOME/.cargo/env"

export FZF_DEFAULT_COMMAND='fd --type f'

