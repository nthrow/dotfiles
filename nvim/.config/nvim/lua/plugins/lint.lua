-- Linting: nvim-lint runs external linters and feeds vim.diagnostic.
-- Extend linters_by_ft as needed (e.g. yamllint, ansible-lint).
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      }
      local grp = vim.api.nvim_create_augroup("UserLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
        group = grp,
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
