-- Debugging for C/C++ with GDB and LLDB, using system packages only.
--
-- LazyVim's dap.core extra provides nvim-dap, nvim-dap-ui and virtual text.
-- The clangd extra tries to install `codelldb` through Mason; mason.lua
-- blocks that download, and this file defines the adapters instead:
--   gdb       : `gdb --interpreter=dap`  (built into GDB 14+; Arch ships newer)
--   lldb-dap  : from the `lldb` package
-- Install with: pacman -S gdb lldb

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }

      local lldb = vim.fn.exepath("lldb-dap")
      dap.adapters.lldb = {
        type = "executable",
        command = lldb ~= "" and lldb or "lldb-dap",
        name = "lldb",
      }

      local function program()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end

      local function args()
        local line = vim.fn.input("Arguments (space separated, empty for none): ")
        return line == "" and {} or vim.split(line, " ", { trimempty = true })
      end

      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            name = "GDB: launch",
            type = "gdb",
            request = "launch",
            program = program,
            args = args,
            cwd = "${workspaceFolder}",
          },
          {
            name = "LLDB: launch",
            type = "lldb",
            request = "launch",
            program = program,
            args = args,
            cwd = "${workspaceFolder}",
          },
          {
            name = "GDB: attach to process",
            type = "gdb",
            request = "attach",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          {
            name = "LLDB: attach to process",
            type = "lldb",
            request = "attach",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },

  -- Never auto-download debug adapters.
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      automatic_installation = false,
      ensure_installed = {},
    },
  },
}
