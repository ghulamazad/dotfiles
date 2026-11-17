-- Global keymaps (always available). Plugin keymaps live next to their plugin in
-- plugins/*.lua, LSP keymaps in lsp/init.lua, Go-only ones in ftplugin/go.lua.
local map = require("ghulamazad.util").map
local has = require("ghulamazad.util").has

map("n", "<leader>pv", vim.cmd.Ex, "Open netrw")

-- Move the selected lines up and down.
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

-- Keep the cursor where it is.
map("n", "J", "mzJ`z", "Join lines, keep cursor")
map("n", "<C-d>", "<C-d>zz", "Half page down, centered")
map("n", "<C-u>", "<C-u>zz", "Half page up, centered")
map("n", "n", "nzzzv", "Next match, centered")
map("n", "N", "Nzzzv", "Previous match, centered")
map("n", "=ap", "ma=ap'a", "Reindent paragraph, keep cursor")

-- Registers and clipboard.
map("x", "<leader>p", [["_dP]], "Paste without overwriting register")
map({ "n", "v" }, "<leader>y", [["+y]], "Yank to system clipboard")
map("n", "<leader>Y", [["+Y]], "Yank line to system clipboard")
map({ "n", "v" }, "<leader>d", [["_d]], "Delete without yanking")

map("i", "<C-c>", "<Esc>", "Leave insert mode")
map("n", "Q", "<nop>", "Disabled (Ex mode)")

-- Quickfix and location list.
map("n", "<C-k>", "<cmd>cnext<CR>zz", "Quickfix: next")
map("n", "<C-j>", "<cmd>cprev<CR>zz", "Quickfix: previous")
map("n", "]l", "<cmd>lnext<CR>zz", "Location list: next")
map("n", "[l", "<cmd>lprev<CR>zz", "Location list: previous")

-- Editing helpers.
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Substitute word under cursor")
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", "chmod +x current file", { silent = true })
map("n", "<leader><leader>", "<cmd>so<CR>", "Source current file")
map("n", "<leader>vlr", "<cmd>lsp restart<CR>", "LSP: restart")

-- Plenary test runner (for Lua plugin development).
map("n", "<leader>tf", "<Plug>PlenaryTestFile", "Plenary: test file", { remap = true })
map("n", "<leader>tb", "<cmd>PlenaryBustedFile %<CR>", "Plenary: busted file")

-- tmux-sessionizer (only when it is installed).
if has("tmux-sessionizer") then
    map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", "tmux-sessionizer (new window)")
    map("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>", "tmux-sessionizer session 0 (vsplit)")
    map("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", "tmux-sessionizer session 0 (new window)")
end
