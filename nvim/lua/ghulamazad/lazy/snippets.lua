return {
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            local ls = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()
            vim.keymap.set({"i"}, "<C-s>e", function() ls.expand() end, {silent = true, desc = "Snippet: expand"})
            vim.keymap.set({"i", "s"}, "<C-s>;", function() ls.jump(1) end, {silent = true, desc = "Snippet: next node"})
            vim.keymap.set({"i", "s"}, "<C-s>,", function() ls.jump(-1) end, {silent = true, desc = "Snippet: previous node"})
        end,
    }
}
