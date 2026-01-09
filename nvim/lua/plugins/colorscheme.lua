-- File: ~/dotfiles/nvim/lua/plugins/colorscheme.lua
return {
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = {
        flavour = "macchiato", 
        transparent_background = true, 
        integrations = {
          telescope = true,
          mason = true,
          which_key = true,
        },
      },
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "catppuccin",
      },
    },
  }