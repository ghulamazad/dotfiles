-- Fuzzy finder. Grep needs ripgrep.
return {
    {
        "nvim-telescope/telescope.nvim",
        enabled = require("ghulamazad.util").feature("telescope"),
        tag = "v0.2.2",
        cmd = "Telescope",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>pf", function() require("telescope.builtin").find_files() end, desc = "Find files" },
            {
                "<C-p>",
                function()
                    local builtin = require("telescope.builtin")
                    if not pcall(builtin.git_files) then
                        builtin.find_files()
                    end
                end,
                desc = "Git files (fallback: find files)",
            },
            { "<leader>pws", function() require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") }) end, desc = "Grep word under cursor" },
            { "<leader>pWs", function() require("telescope.builtin").grep_string({ search = vim.fn.expand("<cWORD>") }) end, desc = "Grep WORD under cursor" },
            { "<leader>ps", function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end, desc = "Grep prompt" },
            { "<leader>vh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
        },
        config = function()
            require("telescope").setup({})

            -- Neovim 0.12 treesitter highlighting for the preview window.
            require("telescope.previewers.utils").ts_highlighter = function(bufnr, ft)
                local lang = vim.treesitter.language.get_lang(ft) or ft
                if not lang or lang == "" then
                    return false
                end
                return pcall(vim.treesitter.start, bufnr, lang)
            end
        end,
    },
}
