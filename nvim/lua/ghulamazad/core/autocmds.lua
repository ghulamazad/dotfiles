-- Autocommands that are not tied to a plugin.
local settings = require("ghulamazad.settings")

local group = vim.api.nvim_create_augroup("GhulamAzad", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    desc = "Briefly highlight yanked text",
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 40 })
    end,
})

if settings.strip_trailing_whitespace then
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        desc = "Strip trailing whitespace (keeps cursor and search pattern)",
        callback = function()
            local view = vim.fn.winsaveview()
            vim.cmd([[keeppatterns %s/\s\+$//e]])
            vim.fn.winrestview(view)
        end,
    })
end
