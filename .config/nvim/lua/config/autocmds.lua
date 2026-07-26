-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
--
-- ~/.config/nvim/lua/config/autocmds.lua

-- Disable wrap when opening markdown files with tables
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Check if file has tables on open (check first 100 lines for speed)
    local lines = vim.api.nvim_buf_get_lines(0, 0, math.min(100, vim.api.nvim_buf_line_count(0)), false)
    local has_table = false
    for _, line in ipairs(lines) do
      if line:match("^|.*|$") then
        has_table = true
        break
      end
    end
    if has_table then
      vim.opt_local.wrap = false
      print("Tables detected - Wrap disabled for better viewing")
    end
  end,
})

-- Auto-disable wrap for markdown files with tables when editing
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*.md",
  callback = function()
    -- Check if current file has a table
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local has_table = false
    for _, line in ipairs(lines) do
      if line:match("^|.*|$") then
        has_table = true
        break
      end
    end
    if has_table then
      vim.opt_local.wrap = false
    end
  end,
})
