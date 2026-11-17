-- Treesitter (`main` branch). Parsers come from settings.lua (`parsers`);
-- installing them needs the tree-sitter CLI and a C compiler.
local settings = require("ghulamazad.settings")
local enabled = require("ghulamazad.util").feature("treesitter")

return {
    {
        "nvim-treesitter/nvim-treesitter",
        enabled = enabled,
        branch = "main",
        build = ":TSUpdate",
        lazy = false,
        init = function()
            local group = vim.api.nvim_create_augroup("GhulamAzadTreesitter", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
                group = group,
                desc = "Start treesitter highlighting when a parser exists",
                callback = function()
                    if vim.bo.buftype == "" then
                        pcall(vim.treesitter.start, 0)
                    end
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                group = group,
                pattern = "VeryLazy",
                once = true,
                callback = function()
                    require("nvim-treesitter").install(settings.parsers)
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        enabled = enabled,
        branch = "main",
        lazy = false,
        config = function()
            require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })

            local select = require("nvim-treesitter-textobjects.select")
            local map = require("ghulamazad.util").map
            map({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end, "Select outer function")
            map({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end, "Select inner function")
        end,
    },
}
