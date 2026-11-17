-- Load order matters: options and keymaps first, then plugins, then the theme.
require("ghulamazad.core.options")
require("ghulamazad.core.keymaps")
require("ghulamazad.core.autocmds")
require("ghulamazad.core.lazy")
require("ghulamazad.commands")

vim.cmd.colorscheme(require("ghulamazad.settings").theme)
