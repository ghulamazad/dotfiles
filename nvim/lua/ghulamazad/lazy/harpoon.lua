return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup()

        vim.keymap.set("n", "<leader>A", function()
            harpoon:list():prepend()
        end, { desc = "Harpoon: prepend file" })
        vim.keymap.set("n", "<leader>a", function()
            harpoon:list():add()
        end, { desc = "Harpoon: add file" })
        vim.keymap.set("n", "<C-e>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Harpoon: quick menu" })

        local slots = { h = 1, j = 2, k = 3, l = 4 }
        for key, idx in pairs(slots) do
            vim.keymap.set("n", "<leader>" .. key, function()
                harpoon:list():select(idx)
            end, { desc = "Harpoon: slot " .. idx })
        end
    end,
}
