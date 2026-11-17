-- Quick file marks (harpoon2). <leader>h j k l jump to slots 1 to 4.
local function list() return require("harpoon"):list() end

local keys = {
    { "<leader>A", function() list():prepend() end, desc = "Harpoon: prepend file" },
    { "<leader>a", function() list():add() end, desc = "Harpoon: add file" },
    { "<C-e>", function() require("harpoon").ui:toggle_quick_menu(list()) end, desc = "Harpoon: quick menu" },
}
for i, key in ipairs({ "h", "j", "k", "l" }) do
    keys[#keys + 1] = { "<leader>" .. key, function() list():select(i) end, desc = "Harpoon: slot " .. i }
end

return {
    {
        "ThePrimeagen/harpoon",
        enabled = require("ghulamazad.util").feature("harpoon"),
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = keys,
        config = function()
            require("harpoon"):setup()
        end,
    },
}
