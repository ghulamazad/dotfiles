-- Keymaps loaded by LazyVim on VeryLazy. LazyVim's defaults are kept; only
-- additions go here. Run :WhichKey to inspect everything, including these.

-- Quick switch between a header and its source (clangd extra also provides <leader>ch).
vim.keymap.set("n", "<leader>cH", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "Switch Source/Header" })
