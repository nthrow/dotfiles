-- Treesitter: syntax/indent via ASTs for the active language set.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- the new default `main` branch dropped the configs.setup API
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "go", "gomod", "gosum", "gowork", "rust",
        "terraform", "hcl", "yaml", "python", "fish",
        "lua", "luadoc", "bash", "markdown", "markdown_inline",
        "json", "toml", "vim", "vimdoc", "diff", "gitcommit", "dockerfile",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
