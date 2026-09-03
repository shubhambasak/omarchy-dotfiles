return {
  -- Add the Catppuccin theme plugin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- or "macchiato", "frappe", "latte"
      transparent_background = false,
      term_colors = true,
    },
  },
  -- Tell LazyVim to use it as the colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
