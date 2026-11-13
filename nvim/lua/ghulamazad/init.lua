require("ghulamazad.set")
require("ghulamazad.remap")
require("ghulamazad.lazy_init")
require("ghulamazad.cmake")

local augroup = vim.api.nvim_create_augroup
local GhulamAzadGroup = augroup("GhulamAzad", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd("TextYankPost", {
    group = yank_group,
    pattern = "*",
    callback = function()
        vim.hl.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = GhulamAzadGroup,
    pattern = "*",
    callback = function()
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

autocmd("LspAttach", {
    group = GhulamAzadGroup,
    callback = function(e)
        local function o(desc) return { buffer = e.buf, desc = desc } end
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, o("LSP: go to definition"))
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, o("LSP: hover"))
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, o("LSP: workspace symbol"))
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, o("Diagnostic: float"))
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, o("LSP: code action"))
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, o("LSP: references"))
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, o("LSP: rename"))
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, o("LSP: signature help"))
        -- Upstream had these two swapped ([d = next). Restored to Vim's native
        -- direction: ]d next, [d previous.
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, o("Diagnostic: next"))
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, o("Diagnostic: previous"))

        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client and client.name == "clangd" then
            vim.keymap.set("n", "<leader>vsh", "<cmd>LspClangdSwitchSourceHeader<CR>", o("clangd: switch source/header"))
        end
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
