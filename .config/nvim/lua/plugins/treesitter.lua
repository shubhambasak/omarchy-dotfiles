return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "markdown",
      "markdown_inline",
      -- ... other parsers you want
    },
    auto_install = true,
  },
}
