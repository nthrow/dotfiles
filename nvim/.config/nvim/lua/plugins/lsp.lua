-- LSP: mason (installer) + mason-lspconfig (bridge) + nvim-lspconfig.
-- nvim 0.11 native flow: vim.lsp.config() for overrides, mason-lspconfig
-- auto-enables installed servers via vim.lsp.enable. Rust is owned by
-- rustaceanvim (see plugins/rust.lua), so it is excluded from auto-enable.
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "mason-org/mason.nvim",
        -- mason installs LSP server *binaries*; they must sit on an exec
        -- filesystem (see lua/config/lazy.lua for $NVIM_EXEC_DIR rationale).
        opts = function()
          local exec_dir = vim.env.NVIM_EXEC_DIR
          if exec_dir ~= nil and exec_dir ~= "" then
            return { install_root_dir = exec_dir .. "/mason" }
          end
          return {}
        end,
      },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "j-hui/fidget.nvim", opts = {} }, -- LSP progress UI
    },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        virtual_text = { spacing = 2, source = "if_many" },
        signs = true,
      })

      -- Buffer-local keymaps once a server attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(ev)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          local tb = require("telescope.builtin")
          map("gd", tb.lsp_definitions, "Goto definition")
          map("gr", tb.lsp_references, "References")
          map("gI", tb.lsp_implementations, "Goto implementation")
          map("<leader>D", tb.lsp_type_definitions, "Type definition")
          map("<leader>fs", tb.lsp_document_symbols, "Document symbols")
          map("<leader>fS", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
          map("K", vim.lsp.buf.hover, "Hover docs")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
            end, "Toggle inlay hints")
          end
        end,
      })

      -- Completion-aware capabilities for every server.
      vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })

      -- Per-server overrides (base configs ship with nvim-lspconfig).
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            usePlaceholders = true,
            analyses = { unusedparams = true, nilness = true, unusedwrite = true },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
          },
        },
      })

      local mason_servers = { "gopls", "terraformls", "ansiblels", "pyright", "yamlls", "bashls" }

      -- lua-language-server has no prebuilt for musl libc, so mason's download
      -- fails there — prefer a system binary when one is on $PATH, otherwise
      -- let mason install it (works on glibc).
      local is_musl = vim.fn.glob("/lib/ld-musl-*") ~= ""
      if is_musl or vim.fn.executable("lua-language-server") == 1 then
        vim.lsp.enable("lua_ls") -- system binary on $PATH
      else
        table.insert(mason_servers, "lua_ls") -- mason installs the glibc build
      end

      require("mason-tool-installer").setup({
        -- shellcheck comes from the system package manager; the rest are
        -- npm/pip/Go-source/static or have prebuilts.
        ensure_installed = {
          "goimports", "gofumpt", "stylua", "shfmt", "prettier", "black",
        },
      })
      require("mason-lspconfig").setup({
        ensure_installed = vim.list_extend(vim.deepcopy(mason_servers), { "rust_analyzer" }),
        automatic_enable = { exclude = { "rust_analyzer" } }, -- rustaceanvim owns Rust
      })
    end,
  },
}
