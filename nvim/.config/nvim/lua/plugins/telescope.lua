-- Telescope: fuzzy finder for files, grep, buffers, and LSP symbols.
return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")

      local builtin = require("telescope.builtin")
      local map = vim.keymap.set
      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
      map("n", "<leader>fr", builtin.resume, { desc = "Resume last picker" })
      map("n", "<leader>f.", builtin.oldfiles, { desc = "Recent files" })
      map("n", "<leader><leader>", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })
    end,
  },
}
