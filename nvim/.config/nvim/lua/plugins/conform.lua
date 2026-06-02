-- Formatting: conform.nvim (replaces the deprecated null-ls). Format on save
-- with LSP fallback; toggle with :lua vim.g.disable_autoformat = true.
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
        rust = { "rustfmt" },
        terraform = { "terraform_fmt" },
        hcl = { "terraform_fmt" },
        python = { "black" },
        lua = { "stylua" },
        sh = { "shfmt" },
        yaml = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },
}
