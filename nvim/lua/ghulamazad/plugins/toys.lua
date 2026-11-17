-- Fun, lazy-loaded: <leader>ca (cellular automaton) and :VimBeGood.
return {
    {
        "Eandrju/cellular-automaton.nvim",
        enabled = require("ghulamazad.util").feature("toys"),
        cmd = "CellularAutomaton",
        keys = { { "<leader>ca", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "Make it rain" } },
    },
    {
        "ThePrimeagen/vim-be-good",
        enabled = require("ghulamazad.util").feature("toys"),
        cmd = "VimBeGood",
    },
}
