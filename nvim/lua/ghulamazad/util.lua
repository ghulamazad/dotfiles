-- Small helpers shared by the other modules.
local M = {}

M.settings = require("ghulamazad.settings")

-- True when `bin` is an executable in PATH.
function M.has(bin)
    return vim.fn.executable(bin) == 1
end

-- True unless the feature is switched off in settings.lua.
function M.feature(name)
    return M.settings.features[name] ~= false
end

-- Keymap with a description (every mapping should have one: `:map <leader>`
-- and telescope's `keymaps` show it). `opts` is merged over the defaults.
function M.map(mode, lhs, rhs, desc, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

-- Reload a Lua module while developing the config: :lua R("ghulamazad.util")
function _G.R(name)
    package.loaded[name] = nil
    return require(name)
end

return M
