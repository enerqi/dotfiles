# Executes commands at login, post-zshrc, for login shells only.
#
# Note: in WezTerm (no mux domain configured here), every new tab/pane is its
# own login shell, so this file runs far more often than "once per session".
# Anything placed here needs its own idempotency/throttle guard (e.g. a
# stamp file keyed on date) rather than relying on this running rarely.
#
# Previously compiled ~/.cache/prezto/zcompdump -> .zwc for faster completion
# loading, but that file is only (re)written when zgenom regenerates its save
# script (rare), and nothing sources it on normal shell startup -- .zshrc's
# own fast-compinit block uses ~/.zcompdump instead. Removed as dead weight.
