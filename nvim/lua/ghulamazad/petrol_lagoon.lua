-- Petrol Lagoon: standalone colourscheme (palette in docs/theme.md).
--
-- No base theme plugin is used. This file defines the editor, syntax,
-- diagnostic, diff and treesitter groups itself. Plugin groups that are not
-- listed here (most link to the standard groups above) follow those links.
-- LIMIT: a plugin group with its own hard-coded colours may look off; add it
-- to `groups` below.
local M = {}

local c = {
    bg = "#0c1618", surface = "#152325", float = "#101c1e", dark = "#081012",
    sel = "#17393d", border = "#2a3f42", muted = "#4d6467",
    fg = "#c2d8d8", fg_hi = "#dfeeee", sub = "#a0b8b8",
    accent = "#35d0c0",
    red = "#e0736e", green = "#6cc48e", yellow = "#d1b366", blue = "#5b9fc4",
    magenta = "#9d8ccc", cyan = "#3fc4b7",
    bred = "#ec8f88", bgreen = "#8adaa8", byellow = "#e2c985",
    bblue = "#7db8d8", bmagenta = "#b5a7dd", bcyan = "#66d9cd",
}
M.colors = c

local function groups()
    return {
        Normal = { fg = c.fg, bg = c.bg },
        NormalNC = { fg = c.fg, bg = c.bg },
        NormalFloat = { fg = c.fg, bg = c.float },
        FloatBorder = { fg = c.border, bg = c.float },
        FloatTitle = { fg = c.accent, bg = c.float, bold = true },
        SignColumn = { bg = c.bg },
        EndOfBuffer = { fg = c.bg },
        LineNr = { fg = c.muted },
        CursorLineNr = { fg = c.accent, bold = true },
        CursorLine = { bg = c.surface },
        ColorColumn = { bg = c.surface },
        Visual = { bg = c.sel },
        VisualNOS = { bg = c.sel },
        Search = { fg = c.fg_hi, bg = c.sel },
        IncSearch = { fg = c.bg, bg = c.accent },
        CurSearch = { fg = c.bg, bg = c.accent },
        MatchParen = { fg = c.accent, bold = true, underline = true },
        WinSeparator = { fg = c.border },
        VertSplit = { fg = c.border },
        StatusLine = { fg = c.fg, bg = c.surface },
        StatusLineNC = { fg = c.muted, bg = c.surface },
        Pmenu = { fg = c.fg, bg = c.float },
        PmenuSel = { fg = c.fg_hi, bg = c.sel },
        PmenuSbar = { bg = c.surface },
        PmenuThumb = { bg = c.muted },
        Folded = { fg = c.sub, bg = c.surface },
        Directory = { fg = c.cyan },
        Title = { fg = c.accent, bold = true },
        NonText = { fg = c.muted },
        Whitespace = { fg = c.border },
        SpecialKey = { fg = c.muted },
        Conceal = { fg = c.muted },
        -- syntax
        Comment = { fg = c.muted, italic = true },
        Constant = { fg = c.yellow },
        String = { fg = c.green },
        Character = { fg = c.green },
        Number = { fg = c.yellow },
        Boolean = { fg = c.yellow },
        Float = { fg = c.yellow },
        Identifier = { fg = c.fg },
        Function = { fg = c.blue },
        Statement = { fg = c.magenta },
        Conditional = { fg = c.magenta },
        Repeat = { fg = c.magenta },
        Label = { fg = c.magenta },
        Operator = { fg = c.cyan },
        Keyword = { fg = c.magenta },
        Exception = { fg = c.magenta },
        PreProc = { fg = c.bcyan },
        Include = { fg = c.magenta },
        Define = { fg = c.magenta },
        Macro = { fg = c.bcyan },
        Type = { fg = c.cyan },
        StorageClass = { fg = c.magenta },
        Structure = { fg = c.cyan },
        Special = { fg = c.bblue },
        Delimiter = { fg = c.sub },
        Todo = { fg = c.bg, bg = c.yellow, bold = true },
        Error = { fg = c.red },
        ErrorMsg = { fg = c.red },
        WarningMsg = { fg = c.yellow },
        -- diagnostics
        DiagnosticError = { fg = c.red },
        DiagnosticWarn = { fg = c.yellow },
        DiagnosticInfo = { fg = c.blue },
        DiagnosticHint = { fg = c.cyan },
        DiagnosticOk = { fg = c.green },
        DiagnosticUnderlineError = { undercurl = true, sp = c.red },
        DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
        DiagnosticUnderlineInfo = { undercurl = true, sp = c.blue },
        DiagnosticUnderlineHint = { undercurl = true, sp = c.cyan },
        -- diff and git signs
        DiffAdd = { bg = "#12301f" },
        DiffChange = { bg = "#14303a" },
        DiffDelete = { bg = "#3a1d1d" },
        DiffText = { bg = c.sel },
        Added = { fg = c.green },
        Changed = { fg = c.blue },
        Removed = { fg = c.red },
        GitSignsAdd = { fg = c.green },
        GitSignsChange = { fg = c.blue },
        GitSignsDelete = { fg = c.red },
        -- plugins in use (telescope, trouble, harpoon, undotree, fugitive)
        TelescopeNormal = { fg = c.fg, bg = c.float },
        TelescopeBorder = { fg = c.border, bg = c.float },
        TelescopePromptNormal = { fg = c.fg, bg = c.surface },
        TelescopePromptBorder = { fg = c.surface, bg = c.surface },
        TelescopePromptTitle = { fg = c.bg, bg = c.accent, bold = true },
        TelescopePreviewTitle = { fg = c.bg, bg = c.green, bold = true },
        TelescopeResultsTitle = { fg = c.float, bg = c.float },
        TelescopeSelection = { fg = c.fg_hi, bg = c.sel },
        TelescopeMatching = { fg = c.accent, bold = true },
        TroubleNormal = { fg = c.fg, bg = c.float },
        HarpoonBorder = { fg = c.border, bg = c.float },
        HarpoonWindow = { fg = c.fg, bg = c.float },
        fugitiveHeading = { fg = c.accent, bold = true },
        -- treesitter groups that do not link to the classic ones above
        ["@variable"] = { fg = c.fg },
        ["@variable.builtin"] = { fg = c.bred },
        ["@variable.parameter"] = { fg = c.bmagenta },
        ["@property"] = { fg = c.bcyan },
        ["@field"] = { fg = c.bcyan },
        ["@constructor"] = { fg = c.bblue },
        ["@punctuation"] = { fg = c.sub },
        ["@tag"] = { fg = c.red },
        ["@tag.attribute"] = { fg = c.yellow },
        ["@markup.heading"] = { fg = c.accent, bold = true },
        ["@markup.link"] = { fg = c.blue, underline = true },
    }
end

function M.apply()
    for name, spec in pairs(groups()) do
        vim.api.nvim_set_hl(0, name, spec)
    end
    local term = { c.surface, c.red, c.green, c.yellow, c.blue, c.magenta, c.cyan, c.sub,
                   c.muted, c.bred, c.bgreen, c.byellow, c.bblue, c.bmagenta, c.bcyan, c.fg_hi }
    for i, color in ipairs(term) do
        vim.g["terminal_color_" .. (i - 1)] = color
    end
end

-- Called by colors/petrol-lagoon.lua: reset everything, then paint our groups.
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
