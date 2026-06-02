-- UI: which-key (keybind discovery) and the mini.nvim suite (statusline,
-- surround, pairs, textobjects). The colorscheme is the built-in `retrobox`,
-- applied in lua/config/options.lua (no plugin needed). See NEOVIM.md.
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.statusline").setup({ use_icons = false })
      require("mini.surround").setup()
      require("mini.pairs").setup()
      require("mini.ai").setup()
    end,
  },
}
