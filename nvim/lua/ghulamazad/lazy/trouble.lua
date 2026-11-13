return {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup({ })

            vim.keymap.set("n", "<leader>tt", function()
                require("trouble").toggle("diagnostics")
            end, { desc = "Trouble: toggle diagnostics" })

            vim.keymap.set("n", "]t", function()
                require("trouble").next({ skip_groups = true, jump = true })
            end, { desc = "Trouble: next item" })

            vim.keymap.set("n", "[t", function()
                require("trouble").prev({ skip_groups = true, jump = true })
            end, { desc = "Trouble: previous item" })

        end
}
