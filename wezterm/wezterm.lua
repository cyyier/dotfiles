local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- --- Aesthetics Configuration ---

config.color_scheme = 'Catppuccin Macchiato'

-- 1. Use your existing MesloLGS NF font
config.font = wezterm.font('MesloLGS NF', { weight = 'Regular' })
config.font_size = 12.0

-- 2. Refined Background (Acrylic)
config.window_background_opacity = 1
config.win32_system_backdrop = None

-- 3. Title Bar & Decorations
-- "TITLE" keeps the text, "RESIZE" allows dragging the edges
config.window_decorations = "TITLE | RESIZE" 

-- This makes the title bar blend in better with the terminal theme
config.window_frame = {
  font = wezterm.font({ family = 'MesloLGS NF', weight = 'Bold' }),
  font_size = 10.0,
  -- The color of the inactive tab bar / title area
  inactive_titlebar_bg = '#181926', 
  active_titlebar_bg = '#24273a',
}

config.window_padding = {
  left = 10,
  right = 10,
  top = 5,    
  bottom = 10,
}

-- --- Interaction ---

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Default Shell/Program
config.default_prog = { 'wsl.exe', '--cd', '~' }

return config