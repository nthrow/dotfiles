-- General keymaps. LSP/Telescope/plugin maps live with their plugins.
local map = vim.keymap.set

-- Clear search highlight on <Esc>
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- System clipboard, explicit (registers stay separate so deletes never clobber it)
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole (no register)" })

-- Diagnostics navigation (jumps; the float/list live in lsp.lua + telescope)
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Move selected lines up/down keeping indentation
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centred when half-page jumping / searching
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
