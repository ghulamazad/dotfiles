-- Autocmds loaded by LazyVim on VeryLazy.

-- Linux kernel coding style (Documentation/process/coding-style.rst):
-- tabs of width 8, 80-column limit. Applied only inside a kernel tree, so
-- regular C/C++ projects keep the 4-space defaults from options.lua.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotfiles_kernel_style", { clear = true }),
  pattern = { "c", "cpp", "kconfig", "make", "asm", "dts" },
  callback = function(args)
    local kernel = require("util.kernel")
    if kernel.root(vim.api.nvim_buf_get_name(args.buf)) then
      vim.bo[args.buf].expandtab = false
      vim.bo[args.buf].tabstop = 8
      vim.bo[args.buf].shiftwidth = 8
      vim.bo[args.buf].textwidth = 80
      vim.wo.colorcolumn = "80"
      -- No format-on-save in the kernel: avoids unrelated whitespace changes
      -- in patches. Format deliberately with <leader>cf.
      vim.b[args.buf].autoformat = false
    end
  end,
})
