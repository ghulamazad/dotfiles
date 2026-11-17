-- Language servers. Which servers run is decided in settings.lua (`servers`);
-- the setup code is lua/ghulamazad/lsp/init.lua. nvim-lspconfig is only used for
-- its default server definitions.
local util = require("ghulamazad.util")

return {
    {
        "neovim/nvim-lspconfig",
        enabled = util.feature("lsp"),
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "mason-org/mason.nvim", enabled = util.feature("mason") },   -- puts mason's bin in PATH first
            { "hrsh7th/cmp-nvim-lsp", enabled = util.feature("completion") },
            "j-hui/fidget.nvim",
        },
        config = function()
            require("fidget").setup({})
            require("ghulamazad.lsp").setup()
        end,
    },
}
