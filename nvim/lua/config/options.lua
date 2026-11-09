-- Options loaded by LazyVim before plugins. See :help option-list.

local opt = vim.opt

opt.relativenumber = true
opt.scrolloff = 8
opt.colorcolumn = "100"
opt.clipboard = "unnamedplus" -- needs wl-clipboard on Wayland
opt.undofile = true

-- Default indentation. Kernel buffers override this in config/autocmds.lua.
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4

-- One status line for all windows keeps the screen uncluttered.
opt.laststatus = 3
