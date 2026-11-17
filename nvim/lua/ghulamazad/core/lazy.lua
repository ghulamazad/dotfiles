-- lazy.nvim bootstrap. Plugin specs are the files in lua/ghulamazad/plugins/.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
        return
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("ghulamazad.plugins", {
    change_detection = { notify = false },
    rocks = { enabled = false },
    install = { colorscheme = { require("ghulamazad.settings").theme } },
    defaults = { lazy = true },
})
