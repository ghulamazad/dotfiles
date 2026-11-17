-- Language server setup, driven by `servers` in settings.lua.
-- Called from plugins/lsp.lua once nvim-lspconfig (which ships the default
-- server definitions) is on the runtimepath.
local util = require("ghulamazad.util")
local map = util.map

local M = {}

local function on_attach(e)
    local function m(mode, lhs, rhs, desc)
        map(mode, lhs, rhs, desc, { buffer = e.buf })
    end
    m("n", "gd", vim.lsp.buf.definition, "LSP: go to definition")
    m("n", "K", vim.lsp.buf.hover, "LSP: hover")
    m("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "LSP: workspace symbol")
    m("n", "<leader>vd", vim.diagnostic.open_float, "Diagnostic: float")
    m("n", "<leader>vca", vim.lsp.buf.code_action, "LSP: code action")
    m("n", "<leader>vrr", vim.lsp.buf.references, "LSP: references")
    m("n", "<leader>vrn", vim.lsp.buf.rename, "LSP: rename")
    m("i", "<C-h>", vim.lsp.buf.signature_help, "LSP: signature help")
    m("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Diagnostic: next")
    m("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Diagnostic: previous")

    local client = vim.lsp.get_client_by_id(e.data.client_id)
    if client and client.name == "clangd" then
        m("n", "<leader>vsh", "<cmd>LspClangdSwitchSourceHeader<CR>", "clangd: switch source/header")
    end
end

function M.setup()
    -- Completion capabilities for every server (only when completion is on).
    if util.feature("completion") then
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok then
            vim.lsp.config("*", { capabilities = cmp_lsp.default_capabilities() })
        end
    end

    for name, server in pairs(util.settings.servers) do
        if util.has(server.bin) then
            local config = server.config
            if type(config) == "function" then
                config = config()
            end
            if config and next(config) then
                vim.lsp.config(name, config)
            end
            vim.lsp.enable(name)
        end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("GhulamAzadLsp", { clear = true }),
        callback = on_attach,
    })

    vim.diagnostic.config({
        float = { focusable = false, style = "minimal", border = "rounded", source = true, header = "", prefix = "" },
    })
end

return M
