-- Rust: rustaceanvim wraps rust-analyzer with Rust-specific commands (expand
-- macro, runnables, debug). It configures the LSP itself — do NOT also enable
-- rust_analyzer via lspconfig (see plugins/lsp.lua's automatic_enable exclude),
-- and do NOT call its setup().
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    config = function()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      vim.g.rustaceanvim = {
        server = {
          capabilities = ok and cmp_lsp.default_capabilities() or nil,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = true,
              inlayHints = { enable = true },
            },
          },
        },
      }
    end,
  },
}
