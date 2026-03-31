# Nushell Environment Config File
#
# version = "0.111"

# =============================================
# Nushell Improved Config (2026 best practices)
# Minimal overrides + autoload + modules
# =============================================

# === Core Settings (only override what you need) ===
$env.config.show_banner = false
$env.config.rm.always_trash = true
$env.config.history = {
    file_format: "sqlite"
    max_size: 5_000_000
    sync_on_enter: true
    isolation: true
}
$env.config.edit_mode = "emacs"   # or "vi"
$env.config.cursor_shape = {
    emacs: "line"
    vi_insert: "line"
    vi_normal: "block"
}
$env.config.buffer_editor = "subl"   # or "code", "hx", "nvim", etc.

# === Prompt: Starship (via autoload) ===
# The actual prompt logic is in autoload/starship.nu

# === Completions: Carapace (via autoload) ===
source ($nu.default-config-dir | path join "cache" "carapace" "init.nu")

# === Custom Modules (your own aliases, functions, etc.) ===
# Load everything from the modules directory
use ($nu.default-config-dir | path join "modules" "aliases.nu") *

# Optional: Load additional user autoload files if you create more
# (anything in ~/.config/nushell/autoload/ gets auto-sourced)

# Example custom command
# export def "git main" [] {
#     git checkout main
# }

# === Final tweaks ===
$env.config = ($env.config | update completions.external {
    enable: true
    max_results: 100
    completer: $carapace_completer  # defined by carapace init
})
