-- Editor options. Keep these opinionated but minimal; plugins own their own.
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.showmode = false -- statusline shows the mode

-- Use the terminal's own 16-color palette instead of truecolor, so Neovim
-- inherits the terminal theme (e.g. ghostty's Retro theme + custom palette)
-- and the terminal's background transparency/blur shows through.
opt.termguicolors = false

-- Clipboard: deliberately NOT synced to the system clipboard. With
-- clipboard=unnamedplus, `dG`/`x`/`c` overwrite the system clipboard, clobbering
-- anything copied out-of-band before you paste it back. Keep nvim registers
-- separate; use the explicit <leader>y / <leader>p maps (keymaps.lua) to reach
-- the system clipboard, and terminal paste works unaffected.

-- Indentation: 2 spaces by default; filetype plugins (Go, etc.) override.
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- UI
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split" -- live preview of :substitute

-- Files / undo
opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400

-- Completion behaviour
opt.completeopt = { "menu", "menuone", "noselect" }

-- Colorscheme: retrobox is a built-in retro theme (no plugin, no native libs).
-- Keep the background transparent so the terminal's
-- opacity/blur is preserved, and re-apply on any :colorscheme change.
opt.background = "dark"
pcall(vim.cmd.colorscheme, "retrobox")

local function keep_transparent()
  for _, group in ipairs({
    "Normal", "NormalNC", "NormalFloat", "SignColumn",
    "LineNr", "EndOfBuffer", "FoldColumn", "CursorLineNr",
  }) do
    vim.api.nvim_set_hl(0, group, { ctermbg = "NONE", bg = "NONE" })
  end
end
keep_transparent()
vim.api.nvim_create_autocmd("ColorScheme", { callback = keep_transparent })
