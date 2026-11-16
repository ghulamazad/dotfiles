vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.api.nvim_set_keymap("n", "<leader>tf", "<Plug>PlenaryTestFile",
    { noremap = false, silent = false, desc = "Plenary: test file" })
vim.keymap.set("n", "<leader>tb", function()
    vim.cmd [[ PlenaryBustedFile % ]]
end, { desc = "Plenary: busted file" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines, keep cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match, centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous match, centered" })
vim.keymap.set("n", "=ap", "ma=ap'a", { desc = "Reindent paragraph, keep cursor" })
vim.keymap.set("n", "<leader>vlr", "<cmd>lsp restart<cr>", { desc = "LSP: restart" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")

if vim.fn.executable("tmux-sessionizer") == 1 then
    vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>",
        { desc = "tmux-sessionizer (new window)" })
    vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>",
        { desc = "tmux-sessionizer session 0 (vsplit)" })
    vim.keymap.set("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>",
        { desc = "tmux-sessionizer session 0 (new window)" })
end

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Quickfix: next" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Quickfix: previous" })
vim.keymap.set("n", "]l", "<cmd>lnext<CR>zz", { desc = "Location list: next" })
vim.keymap.set("n", "[l", "<cmd>lprev<CR>zz", { desc = "Location list: previous" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Substitute word under cursor" })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x current file" })

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("GhulamAzadGoMaps", {}),
    pattern = "go",
    callback = function(e)
        local function o(desc) return { buffer = e.buf, desc = desc } end
        vim.keymap.set("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", o("Go: if err return"))
        vim.keymap.set("n", "<leader>ea", "oassert.NoError(err, \"\")<Esc>F\";a", o("Go: assert.NoError"))
        vim.keymap.set("n", "<leader>ef", "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj",
            o("Go: log.Fatalf on err"))
        vim.keymap.set("n", "<leader>el", "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i",
            o("Go: logger.Error on err"))
    end,
})

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end, { desc = "Source current file" })
