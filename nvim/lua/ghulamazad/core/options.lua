-- Editor options. Change values in settings.lua (`options = { ... }`), not here.
local settings = require("ghulamazad.settings")

vim.g.mapleader = settings.leader
vim.g.maplocalleader = settings.leader

-- netrw (the built-in file browser, `<leader>pv`)
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")

local defaults = {
    guicursor = "",           -- keep the block cursor in every mode

    number = true,
    relativenumber = true,

    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,
    smartindent = true,

    wrap = false,

    swapfile = false,
    backup = false,
    undodir = undodir,
    undofile = true,

    hlsearch = false,
    incsearch = true,

    termguicolors = true,
    scrolloff = 8,
    signcolumn = "yes",
    updatetime = 50,
    colorcolumn = "80",
    showtabline = 0,
}

for name, value in pairs(vim.tbl_extend("force", defaults, settings.options or {})) do
    vim.opt[name] = value
end

vim.opt.isfname:append("@-@")
