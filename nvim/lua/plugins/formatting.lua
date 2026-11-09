-- Formatting via conform.nvim (LazyVim's formatter). clang-format reads the
-- project's own .clang-format, so a kernel tree is formatted with the kernel's
-- rules and other projects with theirs. Provided by the `clang` package.
-- Autoformat-on-save is disabled in kernel buffers (config/autocmds.lua) so
-- you never produce whitespace noise in patches.

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
        sh = { "shfmt" },
      },
    },
  },
}
