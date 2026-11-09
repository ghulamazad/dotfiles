-- Bootstrap lazy.nvim, then LazyVim, then extras, then our own plugin specs.
-- Structure follows the official LazyVim/starter repository.
--
-- NETWORK NOTE: the first launch downloads plugins from GitHub. After that,
-- everything works offline. Run `nvim --headless "+Lazy! sync" +qa` once while
-- online (the installer prints this reminder).

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- Extras (all exist in LazyVim's lua/lazyvim/plugins/extras/).
    -- Only extras that are needed; each adds plugins and startup work.
    { import = "lazyvim.plugins.extras.lang.clangd" },    -- clangd + clangd_extensions
    { import = "lazyvim.plugins.extras.dap.core" },       -- nvim-dap + nvim-dap-ui + virtual text
    { import = "lazyvim.plugins.extras.editor.telescope" }, -- Telescope as the picker

    -- Our overrides, in lua/plugins/*.lua. Loaded AFTER the extras so they win.
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false, -- latest commit; LazyVim recommends this
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  -- No background update checks: updates happen only when you run :Lazy sync.
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
