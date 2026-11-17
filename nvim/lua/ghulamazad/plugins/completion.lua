-- Completion (nvim-cmp) and snippets (LuaSnip + friendly-snippets).
local enabled = require("ghulamazad.util").feature("completion")

return {
    {
        "hrsh7th/nvim-cmp",
        enabled = enabled,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local cmp = require("cmp")
            local ls = require("luasnip")
            local select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        ls.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(select),
                    ["<C-n>"] = cmp.mapping.select_next_item(select),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping(function(fallback)
                        if ls.choice_active() then
                            ls.change_choice(1)
                        elseif cmp.visible() then
                            cmp.abort()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                }, {
                    { name = "buffer" },
                }),
            })
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        enabled = enabled,
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
        keys = {
            { "<C-s>e", function() require("luasnip").expand() end, mode = "i", silent = true, desc = "Snippet: expand" },
            { "<C-s>;", function() require("luasnip").jump(1) end, mode = { "i", "s" }, silent = true, desc = "Snippet: next node" },
            { "<C-s>,", function() require("luasnip").jump(-1) end, mode = { "i", "s" }, silent = true, desc = "Snippet: previous node" },
        },
    },
}
