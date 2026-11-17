-- :Mason is a manual installer; nothing is installed automatically. Use it for
-- tools you do not want from pacman (gopls, delve, lua-language-server).
return {
    {
        "mason-org/mason.nvim",
        enabled = require("ghulamazad.util").feature("mason"),
        cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
        opts = {},
    },
}
