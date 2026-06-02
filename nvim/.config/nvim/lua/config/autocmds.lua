-- Autocommands. Format-on-save is owned by conform.nvim (see plugins/conform.lua).
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Highlight on yank",
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Go uses tabs, width 4 (gofmt convention).
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "go",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end,
})

-- Trim trailing whitespace on save for filetypes where it's safe.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = { "*.lua", "*.fish", "*.sh", "*.tf", "*.yaml", "*.yml", "*.md" },
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})
