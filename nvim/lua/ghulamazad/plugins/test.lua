-- Test runner (neotest). Only Go has an adapter: neotest-golang. Rust and C/C++
-- would need cargo-nextest or a specific framework; add an adapter below if you
-- use one.
local function neotest() return require("neotest") end

return {
    {
        "nvim-neotest/neotest",
        enabled = require("ghulamazad.util").feature("test"),
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "fredrikaverpil/neotest-golang",
            "leoluz/nvim-dap-go",
        },
        keys = {
            { "<leader>tr", function() neotest().run.run({ suite = false }) end, desc = "Test: Running Nearest Test" },
            { "<leader>tv", function() neotest().summary.toggle() end, desc = "Test: Summary Toggle" },
            { "<leader>ts", function() neotest().run.run({ suite = true }) end, desc = "Test: Running Test Suite" },
            { "<leader>td", function() neotest().run.run({ suite = false, strategy = "dap" }) end, desc = "Test: Debug Nearest Test" },
            { "<leader>to", function() neotest().output.open() end, desc = "Test: Open test output" },
            { "<leader>ta", function() neotest().run.run(vim.fn.getcwd()) end, desc = "Test: Run all tests in cwd" },
        },
        config = function()
            neotest().setup({
                adapters = {
                    require("neotest-golang")({ testify_enabled = true }),
                },
            })
        end,
    },
}
