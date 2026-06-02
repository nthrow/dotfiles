-- Bootstrap lazy.nvim.
--
-- Compiled plugin artifacts (treesitter parsers, telescope-fzf-native,
-- LuaSnip's jsregexp) are native .so files that must live on an *exec*-mounted
-- filesystem. On hosts where $HOME is mounted `noexec`, set $NVIM_EXEC_DIR to a
-- writable exec path and lazy will install everything there. Defaults to the
-- normal data dir when unset, so this stays portable.
local exec_dir = vim.env.NVIM_EXEC_DIR
local root = ((exec_dir ~= nil and exec_dir ~= "") and exec_dir or vim.fn.stdpath("data")) .. "/lazy"

-- Safety net: if the plugin dir lands on a noexec mount and no $NVIM_EXEC_DIR
-- was provided, native plugins (treesitter parsers, mason binaries) will fail
-- to load. Warn clearly instead of leaving cryptic dlopen errors.
if exec_dir == nil or exec_dir == "" then
  local mounts = io.open("/proc/mounts", "r")
  if mounts then
    local best_mp, best_opts = "", ""
    for line in mounts:lines() do
      local mp, opts = line:match("^%S+%s+(%S+)%s+%S+%s+(%S+)")
      if mp and #mp >= #best_mp and root:sub(1, #mp) == mp then
        local after = root:sub(#mp + 1, #mp + 1)
        if mp == "/" or after == "" or after == "/" then
          best_mp, best_opts = mp, opts
        end
      end
    end
    mounts:close()
    if best_opts:match("noexec") then
      vim.schedule(function()
        vim.notify(
          ("[nvim] plugin dir %q is on a noexec mount — native plugins will fail to load.\n"):format(root)
            .. "Set $NVIM_EXEC_DIR to a writable exec path (e.g. under /opt).",
          vim.log.levels.WARN
        )
      end)
    end
  end
end

local lazypath = root .. "/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  root = root,
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "retrobox", "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
