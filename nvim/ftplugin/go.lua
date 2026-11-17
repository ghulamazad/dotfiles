-- Go-only keymaps (loaded by Neovim for every Go buffer).
local map = require("ghulamazad.util").map
local buf = { buffer = true }

map("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", "Go: if err return", buf)
map("n", "<leader>ea", 'oassert.NoError(err, "")<Esc>F";a', "Go: assert.NoError", buf)
map("n", "<leader>ef", 'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj', "Go: log.Fatalf on err", buf)
map("n", "<leader>el", 'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i', "Go: logger.Error on err", buf)
