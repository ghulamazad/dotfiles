-- clangd tuning on top of LazyVim's lang.clangd extra.
--
-- * clangd comes from the `clang` pacman package, never from Mason (mason = false),
--   so the binary is covered by your normal system updates and works offline.
-- * We pass NO global compiler flags (no -std=..., no fallbackFlags). clangd
--   reads flags from compile_commands.json / compile_flags.txt, which is the
--   only correct source for per-project flags. This is what keeps ordinary
--   C++ flags away from Linux kernel code.
-- * Inside a kernel tree we additionally turn off the features that do not
--   suit it: background indexing of the whole tree, clang-tidy, and
--   include-insertion (kernel headers have their own conventions).
--
-- For the kernel, generate compile_commands.json after building with:
--   python3 scripts/clang-tools/gen_compile_commands.py
-- (script shipped inside the kernel tree). See docs/kernel-dev.md.

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          mason = false,
          -- cmd as a function lets us decide per project root.
          cmd = function(dispatchers, config)
            local kernel = require("util.kernel")
            local root = config and config.root_dir or nil
            local args = {
              "clangd",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
              -- Let clangd ask the system GCC/Clang for their built-in include
              -- paths. Restricted to system compiler paths on purpose: clangd
              -- executes whatever drivers are listed here.
              "--query-driver=/usr/bin/gcc*,/usr/bin/g++*,/usr/bin/cc,/usr/bin/c++,/usr/bin/clang*",
            }
            if root and kernel.root(root) then
              vim.list_extend(args, {
                "--background-index=false",
                "--clang-tidy=false",
                "--header-insertion=never",
              })
              if vim.uv.fs_stat(root .. "/compile_commands.json") then
                table.insert(args, "--compile-commands-dir=" .. root)
              end
            else
              vim.list_extend(args, {
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
              })
            end
            return vim.lsp.rpc.start(args, dispatchers, {
              cwd = config and config.cmd_cwd or nil,
              env = config and config.cmd_env or nil,
              detached = config and config.detached,
            })
          end,
        },
      },
    },
  },
}
