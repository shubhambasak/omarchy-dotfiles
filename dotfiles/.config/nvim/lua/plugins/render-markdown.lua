return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- These options ensure proper integration
    -- table = {
    --   enabled = true,
    --   border = true,
    --   width = "full", -- "full" or "block" or numeric
    --   scroll = true, -- Enable horizontal scrolling for wide tables
    --   -- Optional: Customize table characters
    --   vertical_char = "│",
    --   horizontal_char = "─",
    --   intersection_char = "┼",
    --   top_left_char = "╭",
    --   top_right_char = "╮",
    --   bottom_left_char = "╰",
    --   bottom_right_char = "╯",
    -- },
    file_types = { "markdown" },
    render_modes = { "n", "c", "t" }, -- Normal, Command, Terminal modes
    heading = {
      enabled = true,
      icons = { "█", "▌", "▎", "▍", "▋", "▊" }, -- Custom icons
    },
    code = {
      enabled = true,
      sign = true, -- Show language icon
      width = "full", -- Full width code blocks
    },
    checkbox = {
      enabled = true,
      -- Custom checkbox symbols
      unchecked = "☐",
      checked = "☑",
    },
    bullet = {
      enabled = true,
      icons = { "●", "○", "◆", "◇" },
    },
  },
  ft = { "markdown" }, -- Lazy-load for markdown files
}
