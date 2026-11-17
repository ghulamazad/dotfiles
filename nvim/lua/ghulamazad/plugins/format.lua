-- Formatting (conform.nvim). Formatters and their arguments are set in
-- settings.lua (`formatters`, `formatter_args`). Formats on save; <leader>f formats now.
local settings = require("ghulamazad.settings")

local formatters = {}
for name, args in pairs(settings.formatter_args or {}) do
    formatters[name] = { prepend_args = args }
end

return {
    {
        "stevearc/conform.nvim",
        enabled = require("ghulamazad.util").feature("format"),
        event = "BufWritePre",
        cmd = "ConformInfo",
        keys = {
            { "<leader>f", function() require("conform").format({ bufnr = 0 }) end, desc = "Format buffer" },
        },
        opts = {
            format_on_save = { timeout_ms = 5000, lsp_format = "fallback" },
            formatters_by_ft = settings.formatters,
            formatters = formatters,
        },
    },
}
