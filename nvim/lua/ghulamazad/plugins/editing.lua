-- Small editing helpers: undotree, zen-mode, cloak (hides secrets in .env files).
local util = require("ghulamazad.util")

return {
    {
        "mbbill/undotree",
        enabled = util.feature("undotree"),
        cmd = "UndotreeToggle",
        keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Undotree" } },
    },
    {
        "folke/zen-mode.nvim",
        enabled = util.feature("zen"),
        cmd = "ZenMode",
        opts = { window = { width = 90 } },
        keys = {
            { "<leader>zz", "<cmd>ZenMode<CR>", desc = "Zen mode" },
        },
    },
    {
        "laytan/cloak.nvim",
        enabled = util.feature("cloak"),
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local cloak = util.settings.cloak
            require("cloak").setup({
                enabled = true,
                cloak_character = "*",
                highlight_group = "Comment",
                patterns = {
                    { file_pattern = cloak.file_pattern, cloak_pattern = cloak.cloak_pattern },
                },
            })
        end,
    },
}
