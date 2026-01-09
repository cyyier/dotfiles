local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- --- 1. Aesthetics Configuration ---

config.color_scheme = 'Catppuccin Macchiato'

-- Font Settings
config.font = wezterm.font('MesloLGS NF', { weight = 'Regular' })
config.font_size = 12.0

-- --- 2. Background Image & Opacity ---
config.window_background_opacity = 0.95

config.background = {
    {
        source = {
            File = wezterm.home_dir .. '/dotfiles/assets/wallpapers/terminal_bg.png',
        },
        opacity = 0.2,
        vertical_align = 'Middle',
        horizontal_align = 'Center',
        repeat_x = 'NoRepeat',
        repeat_y = 'NoRepeat',
        hsb = { brightness = 0.5 },
    },
}

-- --- 3. Title Bar & Decorations ---
config.window_decorations = "TITLE | RESIZE" 

config.window_frame = {
  font = wezterm.font({ family = 'MesloLGS NF', weight = 'Bold' }),
  font_size = 10.0,
  inactive_titlebar_bg = '#181926', 
  active_titlebar_bg = '#24273a',
}

config.window_padding = {
  left = 10,
  right = 10,
  top = 5,    
  bottom = 10,
}

-- --- 4. Interaction ---

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Default Shell/Program
config.default_prog = { 'wsl.exe', '--cd', '~' }

return config