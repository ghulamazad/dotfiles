-- Git (vim-fugitive). <leader>gs opens the status window; inside it
-- <leader>p pushes, <leader>P pulls with rebase, <leader>t starts "push -u origin".
return {
    {
        "tpope/vim-fugitive",
        enabled = require("ghulamazad.util").feature("fugitive"),
        cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "GBrowse" },
        keys = {
            { "<leader>gs", "<cmd>Git<CR>", desc = "Git status (fugitive)" },
            { "<leader>gu", "<cmd>diffget //2<CR>", desc = "Diffget target (//2)" },
            { "<leader>gh", "<cmd>diffget //3<CR>", desc = "Diffget merge (//3)" },
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("GhulamAzadFugitive", { clear = true }),
                pattern = "fugitive",
                callback = function(e)
                    local map = require("ghulamazad.util").map
                    local buf = { buffer = e.buf }
                    map("n", "<leader>p", function() vim.cmd.Git("push") end, "Git push", buf)
                    map("n", "<leader>P", function() vim.cmd.Git({ "pull", "--rebase" }) end, "Git pull --rebase", buf)
                    map("n", "<leader>t", ":Git push -u origin ", "Git push -u origin ...", buf)
                end,
            })
        end,
    },
}
