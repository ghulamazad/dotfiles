-- Petrol Lagoon colourscheme. `:colorscheme petrol-lagoon` calls M.load()
-- (see colors/petrol-lagoon.lua). No theme plugin is used.
local M = {}

local c = require("ghulamazad.theme.palette")

-- The 16 terminal colours used by `:terminal` (same order as ghostty's palette).
local terminal = {
    c.surface, c.red, c.green, c.yellow, c.accent, c.magenta, c.cyan, c.fg,
    c.muted, c.bred, c.bgreen, c.byellow, c.bblue, c.bmagenta, c.bcyan, c.fg_hi,
}

function M.apply()
    for name, spec in pairs(require("ghulamazad.theme.highlights")) do
        vim.api.nvim_set_hl(0, name, spec)
    end
    for i, color in ipairs(terminal) do
        vim.g["terminal_color_" .. (i - 1)] = color
    end
end

-- Reset everything, then paint our groups.
function M.load()
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") == 1 then
        vim.cmd("syntax reset")
    end
    vim.o.termguicolors = true
    vim.o.background = "dark"
    vim.g.colors_name = "petrol-lagoon"
    M.apply()
end

return M
