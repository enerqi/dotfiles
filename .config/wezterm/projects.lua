
return {
  -- {
  --   name = "dotfiles",
  --   cwd = wezterm.home_dir .. "/dev/dotfiles",
  --   layout = function(mux, window)
  --     local pane = window:active_pane()
  --     pane:split({ direction = "Right", cwd = wezterm.home_dir .. "/dev/dotfiles" })
  --     pane:split({ direction = "Down", cwd = wezterm.home_dir .. "/dev/dotfiles" })
  --     window:spawn_tab({ cwd = wezterm.home_dir .. "/dev/dotfiles" })
  --   end
  -- },

  -- {
  --   name = "myapi",
  --   cwd = wezterm.home_dir .. "/dev/acme/api",
  --   layout = function(mux, window)
  --     local pane = window:active_pane()
  --     pane:split({ direction = "Right", cwd = wezterm.home_dir .. "/dev/acme/api" })
  --     local tab = window:spawn_tab({ cwd = wezterm.home_dir .. "/dev/acme/api" })
  --     tab:set_title("server")
  --   end
  -- },
}

-- Each workspace auto-opens:
-- - one or more tabs
-- - with nested panes
-- - all cd'd into the project's directory
-- ✔️ Press Ctrl+O → fuzzy search directories & jump into a workspace using zoxide
-- ✔️ Press Ctrl+Shift+S → fuzzy search existing workspaces
