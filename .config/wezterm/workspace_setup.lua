-- The layout engine that builds each project in projects.lua
local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

function M.init(projects)
  for _, project in ipairs(projects) do
    -- create workspace with name
    local tab, pane, window = mux.spawn_window({
      workspace = project.name,
      cwd = project.cwd,
    })

    -- Create custom layout
    if project.layout then
      project.layout(mux, window)
    end
  end

  -- Optional: default workspace when launching
  local gui = mux.get_active_workspace() or projects[1].name
  mux.set_active_workspace(gui)
end

return M
