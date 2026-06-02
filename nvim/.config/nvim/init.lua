-- ~/.config/nvim/init.lua  (base layer — PUBLIC, safe)
--
-- Entry point. Sets the leader keys (must happen before lazy.nvim loads so
-- plugin mappings resolve correctly), then loads config modules and plugins.
-- See NEOVIM.md (repo root) for the design rationale and plugin choices.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
