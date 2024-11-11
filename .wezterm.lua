-- examples
-- https://alexplescan.com/posts/2024/08/10/wezterm/#multiplexing-terminals-levelling-up-key-assignments

-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- Debugging (ctrl shift L), ctrl D to exit etc.
-- myconfig = window:effective_config()
function get_keys(t)
  local keys={}
  for key,_ in pairs(t) do
    table.insert(keys, key)
  end
  table.sort(keys)
  return keys
end



-- This will hold the configuration.
local config = wezterm.config_builder()

-- Launch menu options
local launch_menu = {}
config.launch_menu = launch_menu

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then

  -- Add powershell to launch menu
  table.insert(launch_menu, {
    label = 'PowerShell',
    args = { 'powershell.exe', '-NoLogo' },
  })

  -- Default to nushell on windows
  config.default_prog = { 'nu' }

  -- Find installed visual studio version(s) and add their compilation
  -- environment command prompts to the menu
  for _, vsvers in
    ipairs(
      wezterm.glob('Microsoft Visual Studio/20*', 'C:/Program Files (x86)')
    )
  do
    local year = vsvers:gsub('Microsoft Visual Studio/', '')
    table.insert(launch_menu, {
      label = 'x64 Native Tools VS ' .. year,
      args = {
        'cmd.exe',
        '/k',
        'C:/Program Files (x86)/'
          .. vsvers
          .. '/BuildTools/VC/Auxiliary/Build/vcvars64.bat',
      },
    })
  end
end

table.insert(launch_menu, {
    label = 'Nu',
    args = { 'nu.exe' },
})


-- Appearance settings
-- note wezterm bundles jetbrains mono and nerd font symbols
-- `wezterm ls-fonts`, `wezterm ls-fonts --list-system`
config.window_decorations = "RESIZE"  -- default "TITLE | RESIZE"
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = 'Monokai (dark) (terminal.sexy)'
config.window_background_opacity = 0.95
config.enable_scroll_bar = true
-- config.background = {source = {File = 'C:/Users/Enerqi/Pictures/chi-20201002-rot.png'}}
-- C:\Users\Enerqi\Pictures/chi-20201002.jpg
-- config.font = wezterm.font 'FuraCode Nerd Font Mono'
config.font = wezterm.font 'CaskaydiaCove NF Mono'
-- config.font = wezterm.font 'Jetbrains Mono'
-- config.font = wezterm.font('JetBrains Mono', { weight = 'Bold', italic = true })
config.font_size = 14

function dirname(path_str)
    local rev = path_str:reverse()
    local start = rev:find("[/]")
    local endoffset = string.find(rev, "[/]", start+1) --rev:find("/", init=start, plain=true)
    local rdir = rev:sub(start+1, endoffset-1)
    return rdir:reverse()
end

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
    local title = tab_info.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
        return title
    end

    local pane = tab_info.active_pane
    local cwd = pane.current_working_dir
    local cwd_string = tostring(cwd)
    local dirname = dirname(cwd_string)
    if dirname and #dirname > 0 then
        return dirname
    end

    -- Otherwise, use the title from the active pane
    -- in that tab
    return tab_info.active_pane.title
end

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local title = tab_title(tab)
    -- if tab.is_active then
      return {
        { Text = ' ' .. title .. ' ' }
        -- { Background = { Color = 'blue' } },
      }
    -- end
  end
)

-- Quick Select Mode (ctrl shift space)
-- quick select mode is used to quickly select and copy commonly used patterns
-- config.quick_select_patterns
config.quick_select_alphabet = "arstqwfpzxcdneioluyhvkgmbj"

-- Copy Mode (ctrl shift x)
-- text selections from keyboard movements.
-- `y` (or 'c') to exit copy with text copied.
-- 'v' (or 'ctrl t'), shift v ('ctrl l'), ctrl v ('space') for cell, line and rectangular selection


-- Key bindings
-- https://wezfurlong.org/wezterm/config/default-keys.html
-- wezterm show-keys --lua
if wezterm.gui then
    local copy_mode = wezterm.gui.default_key_tables().copy_mode
    table.insert(copy_mode, { key = 'LeftArrow', mods = 'CTRL', action = act.CopyMode 'MoveBackwardWord' })
    table.insert(copy_mode, { key = 'RightArrow', mods = 'CTRL', action = act.CopyMode 'MoveForwardWord' })
    table.insert(copy_mode, { key = 'Space', mods = 'NONE', action = act.CopyMode {SetSelectionMode = 'Cell'} })
    table.insert(copy_mode, { key = 't', mods = 'CTRL', action = act.CopyMode {SetSelectionMode = 'Block'} })
    table.insert(copy_mode, { key = 'l', mods = 'CTRL', action = act.CopyMode {SetSelectionMode = 'Line'} })
    table.insert(copy_mode, { key = 'c', mods = 'NONE', action = act.Multiple{ { CopyTo =  'ClipboardAndPrimarySelection' }, { CopyMode =  'Close' } } })
    config.key_tables = { copy_mode = copy_mode }
end
config.keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to be potentially recognized and handled by the tab
  { key = 'm', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment},  -- "hide or minimize"
  { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
}

--* scrolling shift+page up/down
--* ctrl+shift+f search
--* `wezterm imgcat` to render images
--* `wezterm ssh [-h]` for embedded ssh, then new tabs keep the connection!

return config