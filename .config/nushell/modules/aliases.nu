# `export` publishes the alias or def from this module
export alias ll = ls -la
export alias la = ls -a

export alias cat = bat --paging=never
export alias j = just
export alias jw = just --watch
export alias wx = ^watchexec --no-global-ignore

# wrapped accepts extra params, passes them through
export def --wrapped claude-work [...args] {
    with-env {
        CLAUDE_CONFIG_DIR: $"($env.HOME)/.claude-work"
    } {
        ^claude ...$args
    }
}
