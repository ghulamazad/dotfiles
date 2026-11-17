-- Debugging: nvim-dap, its UI panels, and Go support.
-- C, C++ and Rust use gdb's built-in DAP server (gdb 14 or newer); Go uses delve
-- (`dlv` in PATH or :Mason). Start folders for the executable prompt are in
-- settings.lua (`debug.gdb_start_dir`).
--
--   <F8> continue   <F10> over   <F11> into   <F12> out
--   <leader>b / <leader>B   breakpoint / conditional breakpoint
--   <leader>D r s w b S c   toggle one panel full-screen:
--                           repl, stacks, watches, breakpoints, scopes, console
local util = require("ghulamazad.util")
local settings = require("ghulamazad.settings")

-- Ask for the program to debug, starting in `dir` below the project root.
local function exe_prompt(dir)
    return function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. dir, "file")
    end
end

local function setup_gdb(dap)
    if not util.has("gdb") then
        return
    end
    dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }
    for ft, dir in pairs(settings.debug.gdb_start_dir) do
        dap.configurations[ft] = {
            {
                name = "Launch (gdb)",
                type = "gdb",
                request = "launch",
                program = exe_prompt(dir),
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
            {
                name = "Launch with args (gdb)",
                type = "gdb",
                request = "launch",
                program = exe_prompt(dir),
                args = function()
                    return vim.split(vim.fn.input("args> "), " ", { trimempty = true })
                end,
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
        }
    end
end

local function setup_go()
    require("dap-go").setup({
        dap_configurations = {
            { type = "go", name = "file", request = "launch", program = "${file}", outputMode = "remote" },
            {
                type = "go",
                name = "file args",
                request = "launch",
                program = "${file}",
                args = function() return vim.split(vim.fn.input("args> "), " ") end,
                outputMode = "remote",
            },
        },
    })
end

-- One full-width dap-ui layout per panel, toggled by <leader>D<key>.
local panels = { "repl", "stacks", "scopes", "console", "watches", "breakpoints" }

local function setup_ui(dap)
    local dapui = require("dapui")
    local layouts, index = {}, {}
    for i, name in ipairs(panels) do
        layouts[i] = { elements = { { id = name } }, enter = true, size = 40, position = "right" }
        index[name] = i
    end

    dapui.setup({ layouts = layouts, enter = true })

    function _G.GhulamAzadToggleDebugPanel(name)
        dapui.close()
        local ui = vim.api.nvim_list_uis()[1]
        if ui then
            layouts[index[name]].size = ui.width
        end
        pcall(dapui.toggle, index[name])
    end

    local group = vim.api.nvim_create_augroup("GhulamAzadDap", { clear = true })

    -- Wrap long lines in the REPL.
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        pattern = "*dap-repl*",
        callback = function() vim.wo.wrap = true end,
    })

    -- Jump into the REPL / watches window when it opens.
    for _, name in ipairs({ "dap-repl", "DAP Watches" }) do
        vim.api.nvim_create_autocmd("BufWinEnter", {
            group = group,
            pattern = "*" .. name .. "*",
            callback = function(args)
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == args.buf then
                        vim.schedule(function()
                            if vim.api.nvim_win_is_valid(win) then
                                vim.api.nvim_set_current_win(win)
                            end
                        end)
                        return
                    end
                end
            end,
        })
    end

    dap.listeners.before.event_terminated.dapui_config = dapui.close
    dap.listeners.before.event_exited.dapui_config = dapui.close
    dap.listeners.after.event_output.dapui_config = function(_, body)
        if body.category == "console" then
            dapui.eval(body.output)
        end
    end
end

local keys = {
    { "<F8>", function() require("dap").continue() end, desc = "Debug: Continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    {
        "<leader>B",
        function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc = "Debug: Set Conditional Breakpoint",
    },
}
for key, name in pairs({ r = "repl", s = "stacks", w = "watches", b = "breakpoints", S = "scopes", c = "console" }) do
    keys[#keys + 1] = {
        "<leader>D" .. key,
        function() GhulamAzadToggleDebugPanel(name) end,
        desc = "Debug: toggle " .. name .. " ui",
    }
end

return {
    {
        "mfussenegger/nvim-dap",
        enabled = util.feature("debug"),
        keys = keys,
        dependencies = {
            "leoluz/nvim-dap-go",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require("dap")
            dap.set_log_level("DEBUG")
            setup_gdb(dap)
            setup_go()
            setup_ui(dap)
        end,
    },
}
