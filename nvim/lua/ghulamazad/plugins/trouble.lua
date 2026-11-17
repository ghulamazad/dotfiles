-- Diagnostics list. <leader>tt toggles it; ]t / [t move through the items.
return {
    {
        "folke/trouble.nvim",
        enabled = require("ghulamazad.util").feature("trouble"),
        cmd = "Trouble",
        opts = {},
        keys = {
            { "<leader>tt", function() require("trouble").toggle("diagnostics") end, desc = "Trouble: toggle diagnostics" },
            { "]t", function() require("trouble").next({ skip_groups = true, jump = true }) end, desc = "Trouble: next item" },
            { "[t", function() require("trouble").prev({ skip_groups = true, jump = true }) end, desc = "Trouble: previous item" },
        },
    },
}
